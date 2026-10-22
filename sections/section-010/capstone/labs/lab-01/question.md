# Question

Solve this question on: `terminal`

**Time:** about 30 minutes · **Topic:** Harbor architecture and OCI artifacts

## Scenario

The release team keeps the podinfo application in Harbor: the container image and its Helm chart, in the project `inventory`. After a maintenance window, the project is empty, the health report is not clean, and nobody can say which parts of Harbor are running.

The source of truth is the GitHub registry:

- image `ghcr.io/stefanprodan/podinfo:6.15.0`
- Helm chart `ghcr.io/stefanprodan/charts/podinfo:6.15.0` (an OCI artifact)

## Your task

1. Find every Harbor component that is not healthy, and bring it back.
2. Copy the image to `harbor.localtest.me:8443/inventory/podinfo:6.15.0`.
3. Copy the chart to `harbor.localtest.me:8443/inventory/charts/podinfo:6.15.0`.

Use the workstation pod for every Harbor command (`kubectl -n workstation exec -i deploy/workstation -- ...`). The administrator is `admin` with the lab-only password `Harbor12345`.

## Constraints

- Do not reinstall or upgrade the Helm release `harbor`.
- The copies must be the same artifacts as the source, byte for byte: the same digests. Do not rebuild or repackage anything.
- Do not turn TLS off and do not use any `--insecure` option.

## Done when

- The health API reports every component as `healthy`, `trivy` included.
- `inventory/podinfo:6.15.0` has the same digest as the source image.
- `inventory/charts/podinfo:6.15.0` is shown by Harbor as a `CHART` and has the same digest as the source chart.
- The Helm release `harbor` is still at the revision it had when the lab started.
