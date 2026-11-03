# Manifests And Blobs

Every pull from a registry is a series of small HTTP requests for JSON documents and files. If you know what those documents are, a pull that stops half way tells you exactly what is missing. This part copies one image into Harbor and reads its manifest and one of its blobs.

## What a registry stores

A registry stores two kinds of object. A **blob** is a file addressed by the SHA-256 hash of its bytes: a layer of the image file system, or the image configuration. A **manifest** is a JSON document that lists the blobs of one artifact and says what each one is. Both are addressed by a **digest**, written `sha256:` followed by 64 hexadecimal characters.

A **tag** such as `6.15.0` is not an object. It is a name in the repository that points at the digest of one manifest. The tag can move; the digest cannot.

## Copy an image and read its manifest

Create a project, sign in and copy the podinfo image. `regctl` is a client for OCI registries that works without a container engine.

<!-- astrona:playground:renew -->

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws curl -sS -u admin:Harbor12345 -X POST -H 'Content-Type: application/json' \
  -d '{"project_name":"inventory","metadata":{"public":"false"}}' \
  https://harbor.localtest.me:8443/api/v2.0/projects
ws regctl registry login harbor.localtest.me:8443 -u admin -p Harbor12345
ws regctl image copy ghcr.io/stefanprodan/podinfo:6.15.0 harbor.localtest.me:8443/inventory/podinfo:6.15.0
```

If the project already exists, Harbor answers with a conflict, which is fine. Now fetch the document that the tag points at:

```sh
ws regctl manifest get harbor.localtest.me:8443/inventory/podinfo:6.15.0 --format raw-body | ws jq '{schemaVersion, mediaType}'
```

For podinfo the result is not a single image. The media type is an image index. To keep going with one image, ask for the manifest of one platform:

```sh
ws regctl manifest get harbor.localtest.me:8443/inventory/podinfo:6.15.0 --platform linux/amd64 --format raw-body | ws jq
```

The JSON has a `config` object and a list of `layers`. Each entry has a `mediaType`, a `digest` and a `size`. The `config` entry points at the blob that holds the image configuration: the entry point, the environment variables and the history. Each layer entry points at a compressed tar archive of file system changes.

## Read a blob and check its digest

A blob is fetched by repository and digest. The manifest tells you which digest to ask for, so first save the config digest in a shell variable on your own machine:

```sh
CONFIG_DIGEST=$(ws regctl manifest get harbor.localtest.me:8443/inventory/podinfo:6.15.0 --platform linux/amd64 --format raw-body | ws jq -r '.config.digest')
echo "$CONFIG_DIGEST"
ws regctl blob get harbor.localtest.me:8443/inventory/podinfo "$CONFIG_DIGEST" | ws jq '{architecture, os}'
```

The second command prints the architecture and the operating system from the image configuration. The registry stored the blob under its own hash, so you can prove the content is unchanged by hashing it yourself:

```sh
ws sh -c "regctl blob get harbor.localtest.me:8443/inventory/podinfo $CONFIG_DIGEST | sha256sum"
```

The hash equals the part of `$CONFIG_DIGEST` after `sha256:`. This is why a registry can serve the same layer to many images: a layer has one digest, and every manifest that lists it shares the stored blob.

## What a pull does

A pull is the same steps in the other direction. The client resolves the tag to a manifest, reads the manifest, then downloads each blob it lists that the machine does not already have. In Harbor, the `registry` component stores the blobs and manifests, and `core` signs the token that allows each request. A missing blob or a wrong digest makes the pull fail even when the tag resolves.

You now know the two objects a registry stores and how a digest ties them together. The open question is how one tag can serve several processor types.

## Common pitfalls

> [!WARNING]
> - **Treating a tag as the content.** A tag is a pointer. Record the digest when you need to find the same content later.
> - **Reading the layer list as the image size.** The `size` fields are the compressed sizes of the blobs, not the unpacked size on disk.
> - **Asking for a blob with the manifest digest.** Blobs and manifests have different digests; `regctl blob get` needs a blob digest.
> - **Using `--insecure`.** The workstation trusts Harbor's certificate authority. If a request fails on TLS, something else is wrong.
