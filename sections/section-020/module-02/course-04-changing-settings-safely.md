# Changing Settings Safely

Every setting in the chart is changed the same way: by upgrading the release. What differs is what each change does to the running installation. This part gives a routine for changes and a short guide to which settings need extra care.

## The routine

1. Read the current values and save them to a file.
2. Preview the change with `--dry-run`.
3. Apply it with `--reuse-values` and the single `--set` option.
4. Check health, the realm of `/v2/` and a push.

<!-- astrona:playground:renew -->

```sh
helm -n harbor get values harbor -o yaml > before.yaml
helm repo add harbor https://helm.goharbor.io
helm -n harbor upgrade harbor harbor/harbor --version 1.19.4 --reuse-values --set externalURL=https://harbor.localtest.me:8443 --dry-run
helm -n harbor upgrade harbor harbor/harbor --version 1.19.4 --reuse-values --set externalURL=https://harbor.localtest.me:8443 --wait
```

The value is the one already set, so the revision is new and nothing visible changes. `--dry-run` shows the manifests without changing the cluster.

## Care by setting

| Setting | What the change does |
| --- | --- |
| `externalURL` | Pods restart; clients use the new realm; the certificate must match |
| `expose.type` | Changes the Service or Ingress; clients lose access until routing fits |
| `expose.tls.*` | A new certificate is served after the pods restart |
| `persistence.*` | Existing claims keep their size and class; moving data is a separate job |
| `secretKey` | Never change it on a running installation |
| `harborAdminPassword` | No effect on an existing account |

After every change, `helm -n harbor history harbor` shows the new revision, and `helm -n harbor rollback harbor <revision>` returns to an earlier one if the change was wrong.

## Common pitfalls

> [!WARNING]
> - **Upgrading without `--reuse-values` or a values file.** Chart defaults replace your settings.
> - **Changing several settings at once.** When something breaks, you cannot tell which change did it.
> - **Skipping the check after the upgrade.** A rollout that finished can still advertise a wrong address.
> - **Editing a ConfigMap or Secret by hand.** The next upgrade overwrites the change.
