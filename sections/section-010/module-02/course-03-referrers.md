# Referrers And Attached Artifacts

A container image should never change after it is built, but teams want to add facts to it later: a signature, a software bill of materials (SBOM, a list of the packages in the image), a note. The OCI distribution model adds these without touching the image. This part attaches a file to an image and finds it again.

## The subject field

A manifest can carry an optional `subject` field with the digest of another manifest. The new manifest is then a **referrer** of that manifest: it points at it, while the original manifest stays byte for byte the same. The new manifest also has an `artifactType`, a media type that says what it is, for example `application/vnd.inventory.release-notes`.

A registry that supports the referrers API lists them for any digest at `/v2/<repository>/referrers/<digest>`. Harbor 2.15 supports it. Signatures made with `cosign` and many SBOMs are stored this way; Harbor calls such objects **accessories** of the image.

## Attach a file

Create a small file and attach it to the image index in the project `inventory` (copy it first with `regctl image copy ghcr.io/stefanprodan/podinfo:6.15.0 harbor.localtest.me:8443/inventory/podinfo:6.15.0` if it is missing). `oras attach` takes the artifact type, the subject reference and one or more files:

<!-- astrona:playground:renew -->

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws sh -c 'echo "podinfo 6.15.0: approved" > /tmp/notes.txt'
ws oras login harbor.localtest.me:8443 -u admin -p Harbor12345
ws sh -c 'cd /tmp && oras attach --artifact-type application/vnd.inventory.notes harbor.localtest.me:8443/inventory/podinfo:6.15.0 notes.txt:text/plain'
```

`oras attach` resolves the tag to a digest first, so the new manifest refers to the digest and not to the tag. The command prints the digest of the new manifest.

## Find the referrers

List what refers to the image:

```sh
ws oras discover harbor.localtest.me:8443/inventory/podinfo:6.15.0
```

The output is a tree: the image is the root and each referrer is a child with its artifact type and digest. Confirm that the tag still points at the same digest as before the attach:

```sh
ws regctl image digest harbor.localtest.me:8443/inventory/podinfo:6.15.0
```

The digest equals the one before the attach. Attaching changed nothing in the image, which is the point of the design: a signature proves a digest, so it must not change the digest.

`regctl` can list referrers too:

```sh
ws regctl artifact list harbor.localtest.me:8443/inventory/podinfo:6.15.0
```

To get the file back, pull the referrer by its digest, which you read from the discover output. Replace `<REFERRER_DIGEST>` with that value:

```sh
ws sh -c 'mkdir -p /tmp/pulled && cd /tmp/pulled && oras pull harbor.localtest.me:8443/inventory/podinfo@<REFERRER_DIGEST> && cat notes.txt'
```

## How Harbor treats them

When a referrer is a known accessory type, such as a `cosign` signature or an SBOM, `core` shows it under the image in the portal and the API. A referrer of an unknown type is still stored and still found by the referrers API. A **tag** on the image index does not appear on the referrer, because the referrer is addressed by its digest.

Deleting the image deletes its accessories in Harbor. Accessories cannot be pushed to a project that does not allow the push, so the project permissions you met for the image apply to them too.

You can now attach and find content that depends on an image. The graded lab asks you to do it under constraints.

## Common pitfalls

> [!WARNING]
> - **Pushing the note as a separate artifact.** `oras push` with a new tag creates an unrelated artifact. Only `oras attach` sets the `subject`.
> - **Attaching to the wrong digest.** A referrer of a child image manifest is not a referrer of the index that the tag points at.
> - **Running `oras attach` outside the file's folder.** The file name in the layer annotation includes the path you gave.
> - **Expecting the portal to show every artifact type.** Harbor lists the accessory types it knows; use `oras discover` for the full list.

## Your mission: Attach Release Notes To An Image

You can now attach a file to an image so that it refers to the image digest. The graded lab gives you an image and a release-notes file, and asks you to attach the file with the right artifact type without moving the tag.

The lab runs in its own cluster, so first pause your playground. Nothing in it is lost:

```sh
astrona stop ats-100-playground-010-02
```

Then start the lab:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS100.git -c sections/section-010/module-02/labs/lab-01
```

The task is on the next page. Solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-010/module-02/labs/lab-01
```

When the lab is done, remove it and start your playground again:

```sh
astrona destroy ats-100-lab-010-02
astrona start ats-100-playground-010-02
```
