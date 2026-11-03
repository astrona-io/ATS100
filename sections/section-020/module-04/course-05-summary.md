# Summary

An upgrade is a controlled change that has a plan, a record and a way back. The `harbor-helm` chart gives the record, and a backup gives the way back when data changed.

## What you learned

A Helm release has a chart version and an application version. `helm search repo harbor/harbor --versions` lists what the repository offers, and `/api/v2.0/systeminfo` shows the Harbor version that is really running. The Harbor project supports upgrading from the previous minor release, so a larger jump goes through each minor release in turn, and the release notes of the target version name the changes to expect.

Before an upgrade, the administrator saves the database, the registry storage, the Helm values and the Secrets that cannot be generated again. An upgrade keeps its values with `--reuse-values` or a values file, because without one of them Helm falls back to the chart defaults. A dry run shows what Helm will apply, `--wait` makes Helm record a failure, and the health API, the system information and a push prove the result.

Helm records every change as a numbered revision. A failed upgrade leaves a revision with the status `failed`, and a rolling update leaves the old pod running next to a new pod that cannot start. `helm rollback` applies an earlier revision as a new revision and keeps the failed one in the history. Uninstalling the release, deleting pods and editing Deployments by hand are not substitutes.

A rollback does not revert the database. `core` migrates the schema when a new version starts, so a rollback across a migration needs a restored backup. The Compose installers have no revisions, so their upgrade uses a copy of the old folder, a migrated `harbor.yml` and a tested backup. Key facts to remember:

- The chart version and the Harbor version are different numbers.
- Keep values with `--reuse-values` or a values file.
- A rollback is a new revision, and the failed one stays.
- Helm never restores data.

<!-- astrona:playground:destroy -->
