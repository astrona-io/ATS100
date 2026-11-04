# Question

Solve this question on: `terminal`

**Time:** about 15 minutes · **Topic:** Scripting the Harbor CLI

## Scenario

The repository `archive/podinfo` collected test tags named `old-1`, `old-2` and `old-3`, and the list will grow. The team wants them removed with a command that can run again later. The `harbor` CLI in the workstation pod is already signed in as `admin` in the context `admin`.

```sh
kubectl -n workstation exec -i deploy/workstation -- harbor version
```

## Your task

1. List the tags of `archive/podinfo` as JSON and select the ones that start with `old-`.
2. Delete each of them with the CLI.
3. Check that only the release tags are left.

## Constraints

- Use the `harbor` CLI. Do not sign in again or change the CLI context.
- Do not delete artifacts, the repository or the project.
- Do not touch the tags `6.14.1` and `6.15.0`.

## Done when

- No tag starting with `old-` is left in `archive/podinfo`.
- The tags `6.14.1` and `6.15.0` are still there.
- The digest of `archive/podinfo:6.15.0` is unchanged.
