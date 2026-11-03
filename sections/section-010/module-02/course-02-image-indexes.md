# Image Indexes And Multi-Architecture Images

One tag, such as `6.15.0`, must work on an Intel machine and on an Arm machine. A single image manifest cannot do that, because its layers contain programs built for one processor. This part reads the document that solves it, the image index, and explains what Harbor shows for it.

## An index lists manifests

An **image index** is a manifest whose entries are other manifests instead of blobs. Each entry carries a `platform` object with the operating system and the architecture, and the digest of the image manifest for that platform. The client reads the index, picks the entry that matches its own platform, and then pulls that image manifest. The media type of an index is `application/vnd.oci.image.index.v1+json`; Docker's older equivalent is `application/vnd.docker.distribution.manifest.list.v2+json`.

## Read the index of podinfo

Copy podinfo into the project `inventory` (it must exist) if it is not there yet then list the entries of its index:

<!-- astrona:playground:renew -->

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws regctl registry login harbor.localtest.me:8443 -u admin -p Harbor12345
ws regctl image copy ghcr.io/stefanprodan/podinfo:6.15.0 harbor.localtest.me:8443/inventory/podinfo:6.15.0
ws regctl manifest get harbor.localtest.me:8443/inventory/podinfo:6.15.0 --format raw-body | ws jq -r '.manifests[] | "\(.platform.os)/\(.platform.architecture) \(.digest)"'
```

Each line shows a platform and the digest of its image manifest. The index itself has a digest too, and that digest is what the tag `6.15.0` points at:

```sh
ws regctl image digest harbor.localtest.me:8443/inventory/podinfo:6.15.0
ws regctl image digest harbor.localtest.me:8443/inventory/podinfo:6.15.0 --platform linux/amd64
```

The first command prints the digest of the index. The second prints the digest of the `linux/amd64` image manifest, which equals the amd64 line of the list above. They are two different objects, and both exist in the repository.

## Pull one platform by digest

A digest reference has the form `repository@sha256:...`. It skips the tag and the index, so it always gives one exact image. Copy the amd64 image out to a second repository by digest and compare:

```sh
AMD64=$(ws regctl image digest harbor.localtest.me:8443/inventory/podinfo:6.15.0 --platform linux/amd64)
ws regctl image copy "harbor.localtest.me:8443/inventory/podinfo@$AMD64" harbor.localtest.me:8443/inventory/podinfo-amd64:6.15.0
ws regctl manifest get harbor.localtest.me:8443/inventory/podinfo-amd64:6.15.0 --format raw-body | ws jq '.mediaType'
```

The copy is a plain image manifest, not an index, because the source was a single platform digest. Pinning by digest is the usual way to deploy exactly what was tested: the digest never changes, while a tag can be moved to a new index.

## What Harbor shows

`core` reads the index and shows one artifact in the repository for the tag. The artifact lists its child manifests as `references`. Read it from the REST API:

```sh
ws curl -sS -u admin:Harbor12345 'https://harbor.localtest.me:8443/api/v2.0/projects/inventory/repositories/podinfo/artifacts/6.15.0' | ws jq '{digest, type, media_type, refs: [.references[].platform.architecture]}'
```

The `references` array holds one entry per platform. In the portal, the artifact row of an index has an expandable list of the child images.

You can now read an index and select a platform by digest. The next question is how a signature or another file gets linked to an image that never changes.

## Common pitfalls

> [!WARNING]
> - **Comparing the index digest with the image digest.** `regctl image digest` without `--platform` prints the index digest. A scanner or a signature may refer to either object.
> - **Assuming a tag has one platform.** A pull on a different architecture gets a different image from the same tag.
> - **Copying by tag when you need an exact image.** Copy by digest to keep it exact.
> - **Expecting an index in every repository.** Images built for one platform have a plain image manifest at the tag.
