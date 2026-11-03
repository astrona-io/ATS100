# Upgrading, Rolling Back And Migrating Harbor

A Harbor installation does not stay at one version. New releases fix security problems in the components and in the images Harbor depends on, so an administrator upgrades Harbor several times a year. An upgrade can go wrong: an image cannot be pulled, a setting is lost, or a component does not become ready. The administrator must know what changed, what to back up first, and how to return to a working release.

This module covers the upgrade of a Harbor release that was installed with the `harbor-helm` chart, and describes the same task for the Docker Compose installers. Helm records every change to a release as a numbered revision, and that record is the tool for undoing a failed change.

The module has four parts. **Planning An Upgrade** reads the versions, the upgrade rule and the backup list. **Previewing And Applying An Upgrade** keeps values safe and checks the result. **When An Upgrade Fails** reads the Helm history and rolls back; a graded lab follows it. **Database Migrations, Backups And Compose Upgrades** explains what a Helm rollback cannot undo.

## Learning objectives

After this module you can:

- Tell the chart version from the Harbor version and find newer chart versions with Helm.
- State what to back up before an upgrade.
- Preview an upgrade with `helm upgrade --dry-run` and keep the current values with `--reuse-values` or a values file.
- Check an upgrade with the health API, the system information and the pods.
- Read `helm history`, find a failed revision and roll back with `helm rollback`.
- Explain why a rollback does not undo a database migration.
- Describe how the Docker Compose installers are upgraded.

## Before you start

You need to know what a Helm release and a Deployment are, and the commands `helm list`, `helm get values` and `kubectl get pods`. You do not need to know Harbor.

Your playground is a single-node `kind` cluster with **Harbor 2.15.4** installed as the Helm release `harbor` in the namespace `harbor`, chart `harbor` version 1.19.4. Helm 3.22.1 runs on your machine. Harbor answers at `https://harbor.localtest.me:8443`; the administrator is `admin` with the lab-only password `Harbor12345`. Harbor commands run in the **workstation** pod, which has `regctl`, `oras`, `curl` and `jq`:

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
```

The first start takes several minutes. Launch your playground now and keep it running while you read:

<!-- astrona:playground -->
