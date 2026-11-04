# Summary

Moving from the Compose installer to the Helm chart is a translation of settings plus a copy of data, and the order matters.

## What you learned

`harbor.yml` is rendered by `prepare` into container configuration; Helm values are rendered by `helm upgrade` into Kubernetes objects. The names differ, and Helm ignores unknown keys without an error, so a `harbor.yml` cannot be used as a values file. Common settings map as `external_url` to `externalURL`, `log.level` to `logLevel`, `jobservice.max_job_workers` to `jobservice.maxJobWorkers` and `trivy.ignore_unfixed` to `trivy.ignoreUnfixed`; the chart's `helm show values` is the authority for the exact names.

`data_volume`, the certificate paths and the passwords change meaning: volumes become claims, certificates become a Secret, and the old `secretKey` must be carried over. A migration freezes writes, backs up, installs the same Harbor version with the same `secretKey`, restores the database, copies the blobs, switches the address and checks by digest, and upgrades only afterwards. Key facts to remember:

- Search `helm show values` for the chart name of every setting.
- A wrong key name is ignored silently.
- Carry the old `secretKey` into the new installation.
- Migrate first, upgrade second.

<!-- astrona:playground:destroy -->
