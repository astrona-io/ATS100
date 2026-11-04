# From harbor.yml To Helm Values

Teams that ran Harbor with the Docker Compose installer have one file that holds their settings: `harbor.yml`. The Helm chart has no such file. It has values, with different names and a different structure, and some settings do not exist in it at all. Moving without a map either loses a setting silently or breaks the installation.

The module has four parts. **Two Ways To Configure Harbor** compares the files and the processes. **Mapping Settings** translates the settings of `harbor.yml` into chart values; a graded lab follows it. **Settings That Change Meaning** covers data, TLS and secrets, which cannot be copied one to one. **Moving The Data** lists what to carry from Compose to Kubernetes and in which order.

## Learning objectives

After this module you can:

- Describe how `harbor.yml` and `prepare` differ from Helm values.
- Translate common settings of `harbor.yml` into chart values.
- Find the chart name of a setting with `helm show values`.
- Explain what replaces `data_volume`, the certificate paths and the database password.
- List the steps of a migration, with the data copied before the switch.

## Before you start

You should know the Docker Compose installer at a high level and the Helm chart settings from the module on exposure and secrets. You need `helm get values` and `--reuse-values`.

Your playground is a single-node `kind` cluster with **Harbor 2.15.4** installed as the Helm release `harbor` in the namespace `harbor` (chart 1.19.4). Client tools run in the **workstation** pod:

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
```

The first start takes several minutes. Launch your playground now and keep it running while you read:

<!-- astrona:playground -->
