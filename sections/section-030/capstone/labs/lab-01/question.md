# Question

Solve this question on: `terminal`

**Time:** about 30 minutes · **Topic:** The Harbor CLI

## Scenario

An auditor wants a list of everything stored in the project `inventory`: every repository, every tag, and the digest each tag points at. The audit rules say the report must be made with read-only rights, so the auditor can trust that nothing was changed while it was made.

The user `inventory-reader` (password `Inventory-read-123`, lab-only) is a Guest in `inventory`. The `harbor` CLI in the workstation pod is currently signed in as `admin`.

## Your task

In the workstation pod:

1. Save a context for `inventory-reader` at `https://harbor.localtest.me:8443` and make it the current context.
2. With the `harbor` CLI, build the report `/root/inventory-report.json`: a JSON array with one object per tag in every repository of `inventory`. Each object has exactly these fields:
   - `repository`: the full repository name, for example `inventory/podinfo`
   - `tag`: the tag name, for example `6.15.0`
   - `digest`: the digest the tag points at, for example `sha256:...`

## Constraints

- Leave `inventory-reader`'s role as it is (Guest).
- Use the CLI's JSON output (`-o json`), not the table output.

## Done when

- The CLI's current credential is `inventory-reader` at `https://harbor.localtest.me:8443`.
- `/root/inventory-report.json` lists every tag of every repository in `inventory` with the right digest, and nothing else.
- `inventory-reader` is still a Guest in `inventory`.
