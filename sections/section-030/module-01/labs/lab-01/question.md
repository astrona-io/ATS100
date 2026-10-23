# Question

Solve this question on: `terminal`

**Time:** about 15 minutes · **Topic:** The Harbor CLI

## Scenario

The developer `inventory-dev` uses the `harbor` CLI in the workstation pod. After a week away, every command fails. The user's Harbor password is `Inventory-dev-123` (lab-only), and it works in the web portal. The CLI was used against more than one server in the past, and nobody remembers which one it points at now.

Reproduce it:

```sh
kubectl -n workstation exec -it deploy/workstation -- harbor project list
```

## Your task

Make the `harbor` CLI in the workstation pod work as `inventory-dev` against `https://harbor.localtest.me:8443`:

1. Find which context the CLI uses and where it points.
2. Make the current context use `inventory-dev` at `https://harbor.localtest.me:8443` with a working password.
3. Make `harbor project list` show the project `inventory`.

## Constraints

- Use the user `inventory-dev`, not `admin`.
- Do not change `inventory-dev`'s password in Harbor. The password is right; the CLI's saved credentials are not.

## Done when

- The CLI's current credential is user `inventory-dev` at `https://harbor.localtest.me:8443`.
- `harbor project list` in the workstation succeeds and shows `inventory`.
- `inventory-dev` still signs in to Harbor with `Inventory-dev-123`.
