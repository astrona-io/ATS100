# Solution: Attach Release Notes To An Image

Work the task yourself first. Running `astrona submit -c sections/section-010/module-02/labs/lab-01` after a step tells you which checks pass.

The grader checks that a referrer of the right artifact type points at the image digest, that the tag did not move, that Harbor is healthy, and that the Helm release revision did not change.

## Step 1: Read the digest of the tag

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws regctl image digest harbor.localtest.me:8443/inventory/podinfo:6.15.0
```

The command prints a `sha256:` digest. This is the digest of the image index that the tag names. It is the subject the note must refer to.

## Step 2: Attach the file

`oras attach` pushes a new manifest whose `subject` field is the digest of the existing artifact. Sign in first, then attach:

```sh
ws oras login harbor.localtest.me:8443 -u admin -p Harbor12345
ws sh -c 'cd /tmp && oras attach --artifact-type application/vnd.inventory.release-notes \
  harbor.localtest.me:8443/inventory/podinfo:6.15.0 release-notes.txt:text/plain'
```

The command resolves the tag to the digest, so the file refers to the digest and not to the tag. Running it from `/tmp` keeps the file name `release-notes.txt` in the layer annotation.

## Step 3: Prove it

```sh
ws oras discover harbor.localtest.me:8443/inventory/podinfo:6.15.0
ws regctl image digest harbor.localtest.me:8443/inventory/podinfo:6.15.0
```

The first command lists the referrer with the type `application/vnd.inventory.release-notes`. The second prints the same digest as in step 1.

## Step 4: Submit

```sh
astrona submit -c sections/section-010/module-02/labs/lab-01
```

## Why the shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| `oras push` to `inventory/podinfo:notes` | It creates an unrelated artifact with its own tag. Nothing refers to the image |
| Attaching to a child digest of the index | The image index digest has no referrer, so the check fails |
| Copying the image again | The digest should stay the same, but the task forbids it and it fixes nothing |
