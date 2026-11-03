# Question

Solve this question on: `terminal`

**Time:** about 20 minutes · **Topic:** OCI artifacts

## Scenario

The release team keeps the image `inventory/podinfo:6.15.0` in Harbor. The file `/tmp/release-notes.txt` in the workstation pod holds the approval note for that release. The team wants the note stored in Harbor next to the image, so it travels with it, but they must not change the tag or create a second repository.

Run Harbor tools in the workstation pod (`admin` / `Harbor12345` are lab-only credentials):

```sh
kubectl -n workstation exec -i deploy/workstation -- oras version
```

## Your task

1. Read the digest that the tag `inventory/podinfo:6.15.0` points at.
2. Store `/tmp/release-notes.txt` in Harbor as an OCI artifact with the artifact type `application/vnd.inventory.release-notes`, so that it refers to that image.
3. Show that the image now has a referrer of that type.

## Constraints

- Do not push the file with a new tag or into another repository. It must refer to the existing image.
- Do not copy the image again and do not move the tag `6.15.0`.
- Do not upgrade or reinstall the Helm release `harbor`. Do not use any `--insecure` option.

## Done when

- `oras discover` on the image digest lists an artifact of type `application/vnd.inventory.release-notes`.
- The tag `inventory/podinfo:6.15.0` still points at its original digest.
- Harbor reports every component healthy and the Helm release is at its original revision.
