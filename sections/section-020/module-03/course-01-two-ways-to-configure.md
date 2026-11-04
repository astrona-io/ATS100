# Two Ways To Configure Harbor

The two installers describe the same Harbor in two different ways. Knowing how each one turns a setting into a running component explains why settings cannot be copied between them.

## The Compose installer

The offline or online installer unpacks a directory with `harbor.yml`, a script `prepare` and a generated `docker-compose.yml`. You edit `harbor.yml`, run `./prepare`, and it renders configuration files for each container from templates, then `docker compose up` starts the containers. Every setting has a snake_case name such as `external_url` or `max_job_workers`, grouped into sections such as `log`, `jobservice` and `database`.

## The Helm chart

The chart renders Kubernetes objects from templates and your values. Settings use camelCase names and the chart's own grouping, such as `externalURL`, `logLevel` and `jobservice.maxJobWorkers`. The chart creates ConfigMaps and Secrets itself, so there is no `prepare` step, and the running configuration is always the result of the last `helm upgrade`.

## Look at the chart's settings

<!-- astrona:playground:renew -->

```sh
helm repo add harbor https://helm.goharbor.io
helm show values harbor/harbor --version 1.19.4 | head -60
helm -n harbor get values harbor -o yaml
```

The first listing shows every setting with its default and a comment. The second shows only what this release changes. The difference between the two is what you have configured.

## Common pitfalls

> [!WARNING]
> - **Using `harbor.yml` as a values file.** The key names differ and Helm ignores unknown keys without an error.
> - **Editing the generated ConfigMaps.** The next upgrade overwrites them.
> - **Expecting `prepare` in Kubernetes.** The chart renders everything on `helm upgrade`.
> - **Reading old documentation.** Settings differ between Harbor versions; read the 2.15 documentation and the chart's `values.yaml`.
