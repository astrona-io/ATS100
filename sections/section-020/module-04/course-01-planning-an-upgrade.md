# Planning An Upgrade

An upgrade that starts without a plan has no way back. Before anything changes, the administrator needs three facts: which version is running, which version is available, and what to save in case the new version fails. This part reads the first two from the running release and lists the third.

## Two version numbers

A Helm release has a **chart version** and an **application version**. The chart version is the version of the packaged Kubernetes templates (`1.19.4`). The application version is the Harbor release those templates install (`2.15.4`). The two move separately: a chart can change a template without a new Harbor release.

Read both from the running release:

<!-- astrona:playground:renew -->

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
helm -n harbor list
ws curl -sS -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/systeminfo | ws jq '{harbor_version}'
```

`helm list` shows the chart as `harbor-1.19.4` and the app version `2.15.4`. The `systeminfo` request asks `core` which Harbor version is really running. The two should agree. When they do not, a pod is still running an older image than the release says.

## Find newer versions

Helm reads versions from a chart repository. Refresh the repository index and list the chart versions it offers:

```sh
helm repo update harbor
helm search repo harbor/harbor --versions | head -n 8
```

The columns are the chart name, the chart version, the app version and a description. Pick the target by its app version, then use the chart version of that row in the upgrade command.

## The upgrade rule

The Harbor project supports upgrading from the previous minor release to the next one. A minor release is the middle number: in `2.15.4` the minor release is `15`. To go from `2.13` to `2.15`, upgrade to `2.14` first and check it, and then go to `2.15`. A patch release, such as `2.15.3` to `2.15.4`, can follow directly. Read the release notes and the upgrade page of the Harbor documentation for the target version before you start. They list changed settings and removed features, and the exact supported starting versions, so check them rather than relying on this rule alone.

## What to back up

A backup is the only way back from a failed database migration,. Save these four things before any upgrade:

- The **PostgreSQL database** (`database`): it holds projects, users, policies and artifact records.
- The **registry storage**: the blobs and manifests, either the persistent volumes or the object-storage bucket.
- The **Helm values** of the release.
- The **Secrets** of the release that cannot be generated again, in particular the `secretKey` that encrypts stored passwords.

Save the values now. This file lets you recreate the release exactly:

```sh
helm -n harbor get values harbor -o yaml > harbor-values-backup.yaml
```

The file holds only the values that differ from the chart defaults. Treat it as sensitive: it contains the administrator password in this lab, and in a real installation it can contain keys.

You now know what is installed, what is available, how far one upgrade may go, and what to save. The open question is how to apply the change without losing the values you set.

## Common pitfalls

> [!WARNING]
> - **Confusing the chart version with the Harbor version.** The upgrade command takes the chart version.
> - **Skipping minor releases.** Upgrade through each minor release unless the upgrade page of the target version says otherwise.
> - **Backing up only the database.** Without the registry storage the database points at blobs that no longer exist.
> - **Leaving the backup file on a shared machine.** It can contain passwords.
