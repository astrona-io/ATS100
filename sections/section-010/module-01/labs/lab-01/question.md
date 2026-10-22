# Question

Solve this question on: `terminal`

**Time:** about 15 minutes · **Topic:** Harbor architecture

## Scenario

The team's Harbor in the namespace `harbor` stopped accepting pushes this morning. The web portal still loads and people can sign in, so the team believes Harbor is fine. A push to the project `inventory` fails.

You can reproduce it from the workstation pod (`admin` / `Harbor12345` are lab-only credentials):

```sh
kubectl -n workstation exec -i deploy/workstation -- \
  regctl registry login harbor.localtest.me:8443 -u admin -p Harbor12345
kubectl -n workstation exec -i deploy/workstation -- \
  regctl image copy ghcr.io/stefanprodan/podinfo:6.15.0 harbor.localtest.me:8443/inventory/podinfo:6.15.0
```

## Your task

1. Find every Harbor component that is not healthy, using Harbor's health API and the cluster.
2. Bring those components back.
3. Make a push to the project `inventory` work again.

## Constraints

- Do not reinstall or upgrade the Helm release `harbor`. The installation is correct; something stopped parts of it.
- Do not turn TLS off and do not use any `--insecure` option.

## Done when

- `https://harbor.localtest.me:8443/api/v2.0/health` reports every component as `healthy`.
- A push to the project `inventory` from the workstation succeeds.
- The Helm release `harbor` is still at the revision it had when the lab started.
