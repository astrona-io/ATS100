# Question

Solve this question on: `terminal`

**Time:** about 20 minutes · **Topic:** Installing Harbor

## Scenario

A colleague "tidied up" the Helm values of the team's Harbor yesterday. Since then, the portal still loads and the health report is clean, but every push from the workstation fails with an error about a host the team does not use.

Reproduce it from the workstation pod (`admin` / `Harbor12345` are lab-only credentials):

```sh
kubectl -n workstation exec -i deploy/workstation -- \
  regctl registry login harbor.localtest.me:8443 -u admin -p Harbor12345
kubectl -n workstation exec -i deploy/workstation -- \
  regctl image copy ghcr.io/stefanprodan/podinfo:6.15.0 harbor.localtest.me:8443/inventory/podinfo:6.15.0
```

Harbor is the Helm release `harbor` in the namespace `harbor` (chart `harbor/harbor` version 1.19.4). Helm is on your machine in `/usr/local/bin` or `~/.local/bin`; add that folder to your `PATH` if `helm` is not found.

## Your task

1. Find why the push fails, starting from what the registry tells the client.
2. Correct the Helm release so clients are sent to the right address, `https://harbor.localtest.me:8443`.
3. Make the push above succeed.

## Constraints

- Keep TLS on and keep the certificate the chart generated. Do not use any `--insecure` option.
- Change the release with `helm upgrade`. Do not uninstall it.

## Done when

- The release values set `externalURL` to `https://harbor.localtest.me:8443`.
- The registry's `WWW-Authenticate` header names the realm `https://harbor.localtest.me:8443/service/token`.
- TLS is still enabled, and a push to the project `inventory` from the workstation succeeds.
