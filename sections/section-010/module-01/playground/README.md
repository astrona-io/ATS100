# Find Your Way Around A Running Harbor — Playground

- **ID:** PLAYGROUND
- **Slug:** ats-100-playground-010-01
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground — clean environment, no task, no grading

A single sandbox environment that installs Harbor 2.15.4 and the workstation
pod, then stays running so you can explore the module's topic. Nothing to
submit. Built from the Harbor 2.15 documentation and not yet run.

## Run it

```sh
astrona run -c .
astrona destroy ats-100-playground-010-01
```

`astrona destroy` takes the environment name (`metadata.name` = `ats-100-playground-010-01`), not
the config path. `astrona submit` and `astrona test` do not apply.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `bootstrap/prepare.sh` | Helm, CoreDNS rewrite, Harbor, workstation, starting content |
| `manifests/harbor-values.yaml` | Helm values for Harbor |
| `manifests/lab-start.yaml` | The workstation pod |
| `docs/overview.md` | What the environment contains and ideas to try |
