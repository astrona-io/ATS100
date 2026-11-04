# Question

Solve this question on: `terminal`

**Time:** about 20 minutes · **Topic:** Migrating from Docker Compose

## Scenario

Your team ran Harbor with the Docker Compose installer and now runs it with the Helm chart. The old settings file is `/tmp/harbor.yml` in the workstation pod. The Helm release `harbor` in the namespace `harbor` already works, but three settings of the old file were never moved.

```sh
kubectl -n workstation exec -i deploy/workstation -- cat /tmp/harbor.yml
```

## Your task

1. Read `/tmp/harbor.yml` and find the settings that the release does not have yet.
2. Find the chart values that match them with `helm show values harbor/harbor --version 1.19.4`.
3. Apply them to the existing release.

## Constraints

- Do not uninstall or reinstall the release.
- Keep every other value, including `externalURL` and the certificate settings.
- Do not edit ConfigMaps or Secrets by hand.

## Done when

- The log level is `debug`, the job service runs 20 workers, and Trivy ignores unfixed vulnerabilities, all as Helm values.
- `externalURL` and `expose.tls.certSource` are unchanged.
- Every component is healthy and a push to `inventory` works.
