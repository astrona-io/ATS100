# Images, Helm Charts And Other OCI Artifacts

A team that runs Harbor soon wants to keep more than container images in it: Helm charts, signatures, software bills of materials, even plain configuration files. Harbor can store all of them, because they share one storage format. This part stores a Helm chart and a plain file next to the image, reads how Harbor tells them apart, and explains why a digest, not a tag, is the exact name of an artifact.

## One format for many kinds of content

The Open Container Initiative (OCI) defines how a registry stores and serves content. An **OCI artifact** is anything stored in that format: a **manifest**, which is a small JSON document, plus the **blobs** (layers) it lists. A container image is one kind of artifact. A Helm chart, a signature or a WebAssembly (Wasm) module is another; only the media types in the manifest differ.

Because the format is shared, Harbor's `registry` component stores every kind the same way. `core` reads the media types and shows each artifact with a type: `IMAGE`, `CHART`, or another type for content it does not know.

## Copy a Helm chart

The podinfo project publishes its Helm chart as an OCI artifact on the GitHub registry. Copy it into the project `inventory` with `regctl`, exactly like an image. The project `inventory` and the image `inventory/podinfo:6.15.0` must already exist in your playground; create them with the commands below if you have not.

<!-- astrona:playground:renew -->

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws curl -sS -u admin:Harbor12345 -X POST -H 'Content-Type: application/json' \
  -d '{"project_name":"inventory","metadata":{"public":"false"}}' \
  https://harbor.localtest.me:8443/api/v2.0/projects
ws regctl registry login harbor.localtest.me:8443 -u admin -p Harbor12345
ws regctl image copy ghcr.io/stefanprodan/podinfo:6.15.0 harbor.localtest.me:8443/inventory/podinfo:6.15.0
ws regctl image copy ghcr.io/stefanprodan/charts/podinfo:6.15.0 harbor.localtest.me:8443/inventory/charts/podinfo:6.15.0
```

If the project already exists, the first request answers with a conflict error, which is fine. Now ask Harbor what it stored. A repository name that contains a slash must be encoded twice in the API path, so `charts/podinfo` becomes `charts%252Fpodinfo`:

```sh
ws curl -sS -u admin:Harbor12345 \
  'https://harbor.localtest.me:8443/api/v2.0/projects/inventory/repositories/charts%252Fpodinfo/artifacts/6.15.0' \
  | ws jq '{type, digest, media_type}'
ws curl -sS -u admin:Harbor12345 \
  'https://harbor.localtest.me:8443/api/v2.0/projects/inventory/repositories/podinfo/artifacts/6.15.0' \
  | ws jq '{type, digest, media_type}'
```

The chart shows the type `CHART` and the image shows the type `IMAGE`. Both have a `digest` that starts with `sha256:`. Harbor did not need a separate chart storage for this: in Harbor 2.x, Helm charts are OCI artifacts like everything else.

## Push a plain file with oras

`oras` (OCI Registry As Storage) is a client that pushes and pulls any files as OCI artifacts. It is the tool to use when the content is not an image or a chart. Create a small file in the workstation and push it with an artifact type of your own:

```sh
ws sh -c 'echo "warehouse-a: 120 items" > /tmp/stock.txt'
ws oras login harbor.localtest.me:8443 -u admin -p Harbor12345
ws sh -c 'cd /tmp && oras push harbor.localtest.me:8443/inventory/stock-report:2026-10 \
  --artifact-type application/vnd.inventory.report stock.txt:text/plain'
```

`oras push` prints the digest of the manifest it created. In the portal, the repository `inventory/stock-report` shows one artifact whose type Harbor does not recognise as an image or a chart. You can pull it back anywhere with `oras pull` and the same reference.

## Tags and digests

A **tag** is a movable name for one artifact, such as `6.15.0`. Anyone with push rights can point it at different content tomorrow. A **digest** is the SHA-256 hash of the manifest. It changes when any byte of the content changes, so it names exactly one artifact and can never move.

Compare the digest of the source image and the copy in Harbor:

```sh
ws regctl image digest ghcr.io/stefanprodan/podinfo:6.15.0
ws regctl image digest harbor.localtest.me:8443/inventory/podinfo:6.15.0
```

Both commands print the same `sha256:` value. `regctl image copy` copied the manifest and its blobs without changing a byte, so the copy is the same artifact. This is how you prove a copy, and it is also why deployment tools pin images by digest: a digest that matches is proof, a tag that matches is not.

One artifact can have many tags. Add a second tag by copying inside Harbor, then list the tags:

```sh
ws regctl image copy harbor.localtest.me:8443/inventory/podinfo:6.15.0 harbor.localtest.me:8443/inventory/podinfo:stable
ws regctl tag ls harbor.localtest.me:8443/inventory/podinfo
```

The list shows `6.15.0` and `stable`. In the portal they appear as two tags on one artifact, because the digest is the same; Harbor stored no new blobs.

WebAssembly modules, signatures from Cosign and SBOMs are stored the same way. Harbor shows signatures and SBOMs as **accessories** attached to the artifact they describe, instead of as separate artifacts.

You now know that Harbor stores images, charts and any other content as OCI artifacts, that `core` gives each one a type, and that a digest proves two copies are identical. With the components, the push order and the artifact model in hand, you can read most problems in a running Harbor.

## Common pitfalls

> [!WARNING]
> - **Encoding a nested repository name once.** In API paths, `charts/podinfo` must be written `charts%252Fpodinfo`; a single encoding returns `404`.
> - **Comparing tags to prove a copy.** Two equal tags say nothing about the content. Compare digests.
> - **Expecting a separate chart repository.** Harbor 2.x stores charts as OCI artifacts; the old ChartMuseum storage is gone.
> - **Pushing to a project that does not exist.** Create it first; neither `regctl` nor `oras` creates projects.
