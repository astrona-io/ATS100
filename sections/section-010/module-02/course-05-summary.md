# Summary

A registry stores two kinds of object, manifests and blobs, and every other feature is built on them. Knowing which object a request needs makes a failed pull or a missing signature easy to explain.

## What you learned

A blob is a file addressed by the SHA-256 digest of its bytes. A manifest is a JSON document that lists the config blob and the layer blobs of one artifact. A tag is only a name in a repository that points at a manifest digest, so the digest is the exact identity and the tag can move.

An image index is a manifest that lists image manifests, one for each platform. A client picks the entry that matches its operating system and architecture. The digest of the index and the digest of one platform image are different objects, and copying by digest keeps an image exact.

A manifest with a `subject` field is a referrer of the digest it names. `oras attach` creates one without changing the image, and `oras discover` or `regctl artifact list` lists them. Signatures and SBOMs use the same mechanism, and Harbor shows the known types as accessories.

Harbor adds projects, repositories, artifacts and tags in its database, and keeps them in step with the registry. The REST API walks those levels, uses `%252F` for a slash in a repository name, and returns pages of results. Key facts to remember:

- A digest never changes; a tag can.
- An index digest and an image digest are different.
- A referrer refers to a digest, not to a tag.
- A script must read every page of a list.

<!-- astrona:playground:destroy -->
