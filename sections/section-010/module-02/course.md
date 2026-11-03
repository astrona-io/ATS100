# The OCI Distribution Model: Manifests, Blobs, Indexes And Referrers

An image pulled from Harbor works, but a Harbor administrator must also answer questions the pull does not show. Why does one tag give a different image on an Arm machine than on an Intel machine? What is stored when a signature or a software bill of materials is "attached" to an image? Why does the same repository show one artifact in the portal and several manifests in the registry?

The answers sit in the Open Container Initiative (OCI) distribution model: a few JSON documents that every registry stores in the same way. Harbor adds its own names on top: projects, repositories and artifacts. This module opens those documents and reads them.

The module has four parts. **Manifests And Blobs** reads the manifest of an image and the blobs it lists. **Image Indexes And Multi-Architecture Images** shows how one tag points at several images, one per platform. **Referrers And Attached Artifacts** attaches a file to an image and finds it again; a graded lab follows it. **Harbor's Data Model And The REST API** maps projects, repositories, artifacts and tags to API paths.

## Learning objectives

After this module you can:

- Read an image manifest and say what its config and layer entries are.
- Fetch a blob by digest and check that its content matches the digest.
- Tell an image index from an image manifest by its media type.
- Select one platform of a multi-architecture image by digest.
- Attach a file to an image with `oras attach` and list it with `oras discover`.
- Explain what the `subject` field of a manifest does.
- Build the REST API path of a repository whose name contains a slash.

## Before you start

You need to know what a container image and a registry are, and the commands `kubectl exec` and `curl`. You do not need to know Harbor.

Your playground is a single-node `kind` cluster with **Harbor 2.15.4** in the namespace `harbor`. Harbor answers at `https://harbor.localtest.me:8443`. The administrator is `admin` with the lab-only password `Harbor12345`. Every Harbor command runs in the **workstation** pod, which has `regctl`, `oras`, `cosign`, `harbor`, `curl` and `jq` and already trusts Harbor's certificate authority.

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
```

The first start takes several minutes. Launch your playground now and keep it running while you read:

<!-- astrona:playground -->
