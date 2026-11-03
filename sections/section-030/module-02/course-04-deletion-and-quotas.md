# Safe Deletion And Quotas

Deleting a tag or an artifact in Harbor does not give disk space back at once, and a project can run out of space even when you think it is empty. This part explains what a delete does underneath, how quotas count, and which commands show the numbers.

## A delete removes a reference first

Harbor stores image data as blobs that several artifacts can share. When you delete a tag or an artifact, Harbor removes the database record and the reference to its blobs. The blob files stay in the storage until **garbage collection** runs, because another artifact may still use the same blob. Garbage collection is a scheduled job of the system administrator; it removes only blobs that no artifact references.

## Quotas

A project quota limits storage. The limit is set with `--storage-limit` when the project is created, and `-1` means unlimited. The usage counts the layers of the project once, even when several tags use them. Read the numbers with:

<!-- astrona:playground:renew -->

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
wst() { kubectl -n workstation exec -it deploy/workstation -- "$@"; }
ws harbor login https://harbor.localtest.me:8443 --username admin \
  --password Harbor12345 --context-name admin --skip-verify-client
wst harbor quota list
wst harbor project view inventory
```

`harbor quota list` shows each project with its hard limit and its current usage. A push that would exceed the hard limit is refused. Deleting a tag lowers the usage only when no other artifact shares the layers, and the freed blobs return to the disk after garbage collection.

## Safe cleanup order

1. List what exists with `harbor artifact list` and read the digests.
2. Delete tags with `harbor artifact tags delete` when the image must stay.
3. Delete artifacts only when no tag or deployment needs them.
4. Read `harbor quota list` to see the new usage.
5. Let the scheduled garbage collection free the disk, or ask the administrator to run it.

For regular cleanup, a tag retention rule on the project removes old tags by a rule, which is safer than a hand-written loop.

## Common pitfalls

> [!WARNING]
> - **Expecting free space right after a delete.** The blobs stay until garbage collection runs.
> - **Deleting an artifact that a deployment still pulls.** The next pull fails. Check what uses a digest first.
> - **Setting a quota too low.** Pushes fail with a quota error although the project looks small, because every layer counts.
> - **Looping over `artifact delete` in a script.** One wrong filter removes real images. Print the list first and review it.
