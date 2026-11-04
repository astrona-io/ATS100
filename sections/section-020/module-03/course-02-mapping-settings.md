# Mapping Settings

Most settings of `harbor.yml` have a counterpart in the chart under another name. This part gives the map for the common ones and shows how to find the rest.

## The map

| `harbor.yml` | Chart value |
| --- | --- |
| `hostname` | `expose.ingress.hosts.core` (with `ingress`) |
| `external_url` | `externalURL` |
| `harbor_admin_password` | `harborAdminPassword` |
| `log.level` | `logLevel` |
| `jobservice.max_job_workers` | `jobservice.maxJobWorkers` |
| `database.max_idle_conns`, `database.max_open_conns` | `database.maxIdleConns`, `database.maxOpenConns` |
| `trivy.ignore_unfixed` | `trivy.ignoreUnfixed` |
| `trivy.skip_update` | `trivy.skipUpdate` |
| `metric.enabled` | `metrics.enabled` |
| `proxy.http_proxy` | `proxy.httpProxy` |

Treat this as a starting point. The chart can rename a value between versions, so confirm each name against `helm show values` for the chart version you install.

## Find a setting in the chart

<!-- astrona:playground:renew -->

```sh
helm repo add harbor https://helm.goharbor.io
helm show values harbor/harbor --version 1.19.4 | grep -n -i -E 'logLevel|maxJobWorkers|ignoreUnfixed'
```

Each match shows the line with the setting and its default. Search for the words of the old name without underscores, because the chart uses camelCase.

## Preview before applying

```sh
helm -n harbor upgrade harbor harbor/harbor --version 1.19.4 --reuse-values --set logLevel=debug --dry-run
```

The rendered output contains the new value. Apply the same command without `--dry-run`, then read `helm -n harbor get values harbor` to confirm.

## Common pitfalls

> [!WARNING]
> - **Guessing the chart name.** A wrong key is ignored without an error. Search `helm show values`.
> - **Applying a values file without `--reuse-values` when it holds only some settings.** The rest falls back to defaults.
> - **Moving `log.level: debug` to production.** Debug logs are large and can contain request details.
> - **Moving settings one by one without a check.** Read `helm get values` after each change.

## Your mission: Move Settings From harbor.yml To Helm Values

You can now translate a setting and find the chart name of one that is not in the map. The graded lab gives you an old `harbor.yml` and a Helm release that is missing three of its settings.

The lab runs in its own cluster, so first pause your playground. Nothing in it is lost:

```sh
astrona stop ats-100-playground-020-03
```

Then start the lab:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS100.git -c sections/section-020/module-03/labs/lab-01
```

The task is on the next page. Solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-020/module-03/labs/lab-01
```

When the lab is done, remove it and start your playground again:

```sh
astrona destroy ats-100-lab-020-03
astrona start ats-100-playground-020-03
```
