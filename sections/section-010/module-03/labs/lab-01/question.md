# Question

Solve this question on: `terminal`

**Time:** about 15 minutes · **Topic:** Harbor state and storage

## Scenario

Harbor runs as the Helm release `harbor` in the namespace `harbor`. Users report that they cannot sign in to the portal and that pushes fail. The project `inventory` holds the image `podinfo:6.15.0`, and nobody may lose it.

Harbor commands run in the workstation pod:

```sh
kubectl -n workstation exec -i deploy/workstation -- curl -s https://harbor.localtest.me:8443/api/v2.0/health
```

## Your task

1. Find which component stopped and why Harbor cannot work without it.
2. Bring that component back.
3. Prove that every component is healthy and that `inventory/podinfo:6.15.0` is still there.

## Constraints

- Do not uninstall, upgrade or reinstall the Helm release.
- Do not delete any PersistentVolumeClaim or other data volume.
- Do not edit the Helm values.

## Done when

- The database StatefulSet has one ready replica.
- The health API reports every component as healthy.
- `inventory/podinfo:6.15.0` still has the digest it had before.
