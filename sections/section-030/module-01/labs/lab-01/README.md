---
estimated_duration: 15m
---

# Point The Harbor CLI At The Right Server

- **ID:** LAB
- **Slug:** ats-100-lab-030-01
- **Author:** Paris Nakita Kejser
- **Type:** Astrona graded lab

Graded lab for the harbor CLI configuration in the workstation pod. Read `question.md` for the task; `solution.md` is the walkthrough.
Built from the Harbor 2.15 documentation and not yet run (see the repository `CLAUDE.md`).

## Run it

```sh
astrona run -c .
astrona submit
astrona destroy ats-100-lab-030-01
```

`astrona destroy` takes the environment name (`metadata.name` = `ats-100-lab-030-01`), not
the config path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition, bootstrap and grading |
| `question.md` | The task |
| `solution.md` | Step-by-step walkthrough |
| `prerequisites.md` | Assumed knowledge and what the environment provides |
| `bootstrap/01-install-harbor.sh` | Helm, the CoreDNS rewrite, Harbor and the workstation pod |
| `bootstrap/02-seed-state.sh` | The starting state of the task |
| `manifests/` | Harbor Helm values and the workstation pod |
| `solution/apply.sh` | Reference solution used by `astrona test` |
| `testing/wait-for-harbor.sh` | Waits until Harbor answers |
| `validation/` | Grading scripts, one per check |
