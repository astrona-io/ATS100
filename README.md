# ATS100 — Architecture, Installation & Harbor CLI Basics (Harbor)

Course material for the **Architecture, Installation & Harbor CLI Basics**
domain of the Astrona Harbor training path
([ATP020](https://github.com/astrona-io/ATP020)), which is **10% of the path**.
Written for **Harbor 2.15.4** (chart `harbor-helm` 1.19.4) and the
**Harbor CLI v0.0.27**.

> **Status: draft, not yet run.** Every page, playground and lab was written
> from the Harbor 2.15 documentation, the `harbor-helm` 1.19.4 chart and the
> Harbor CLI v0.0.27 docs. None has been started on a cluster, and no lab has
> passed `astrona test` yet. See `CLAUDE.md`.

The course opens with an Introduction in `sections/intro/` (welcome, machine setup,
how the course is made). Everything else lives under `sections/`. Each section
contains:

- **Modules** — a reading chapter split into a short landing page, ordered
  deep-dive parts and a summary page, a throwaway **playground** to explore in,
  and a graded **lab** placed right after the part it tests.
- **A capstone** — one larger graded lab combining that section's module into a
  single scenario with several independent faults.

---

## Sections

| Section | Title | Modules | Labs | Topic |
| --- | --- | --- | --- | --- |
| [010](sections/section-010) | Harbor Architecture And OCI Artifacts | 1 | 1 + capstone | Architecture |
| [020](sections/section-020) | Installing Harbor With Helm And TLS | 1 | 1 + capstone | Installation |
| [030](sections/section-030) | The Harbor Command-Line Tool | 1 | 1 + capstone | Harbor CLI |

The order goes from a running Harbor to how it is installed, and then to the
tool used every day. Section 010 takes a running Harbor apart, because every
later problem starts with "which component?". Section 020 covers the two
install-time settings that break every client when they are wrong: the
external URL and the certificate. Section 030 ends with the `harbor` CLI.

---

## Modules

| Module | Reader | Parts | Labs |
| --- | --- | --- | --- |
| 010-01 | [Find Your Way Around A Running Harbor](sections/section-010/module-01/course.md) | 3 | [lab-01](sections/section-010/module-01/labs/lab-01) |
| 020-01 | [Install And Configure Harbor With harbor-helm](sections/section-020/module-01/course.md) | 3 | [lab-01](sections/section-020/module-01/labs/lab-01) |
| 030-01 | [Work With Harbor From The Command Line](sections/section-030/module-01/course.md) | 3 | [lab-01](sections/section-030/module-01/labs/lab-01) |

---

## Capstones

| Capstone | Scenario | Faults |
| --- | --- | --- |
| [010](sections/section-010/capstone/labs/lab-01) | Make Harbor Store Images And Charts Again | Redis and Trivy stopped, an empty project to fill with an image and a chart, proven by digest |
| [020](sections/section-020/capstone/labs/lab-01) | Serve Harbor With Your Own Certificate | a certificate for the wrong host name, a workstation that trusts the old CA |
| [030](sections/section-030/capstone/labs/lab-01) | Build A Repository Report With The Harbor CLI | a read-only context to create, a JSON report checked against Harbor |

---

## The lab environment

Every playground and lab is a **kind** cluster with Harbor 2.15.4 installed by
Helm 3.22.1 (`harbor-helm` 1.19.4, `expose.type: clusterIP`, TLS certificate
from a fixed lab CA in the Secret `harbor-tls`, no persistence) and a **workstation** pod (`alpine:3.22`) that
carries the client tools (`harbor` v0.0.27, `cosign` 3.1.4, `oras` 1.3.5,
`regctl` 0.11.7, `curl`, `jq`) and trusts Harbor's CA.

Harbor answers at `https://harbor.localtest.me:8443` everywhere: inside the
cluster through a CoreDNS `rewrite stop` block added by the bootstrap, and on
the reader's machine through `kubectl -n harbor port-forward svc/harbor 8443:8443`.
The administrator is the lab-only `admin` / `Harbor12345`. Each environment
needs about 4 GiB of memory and outbound internet.

The plumbing scripts (install, seed, solution, testing and validation scripts,
`config.yaml` files, author READMEs and `prerequisites.md`) share the same
helper blocks; change a helper in every environment at once.

## Running a playground

```bash
astrona run --git ssh://git@github.com/astrona-io/ATS100.git -c sections/<section>/<module>/playground
astrona destroy <name>
```

## Running a lab

Labs and capstones are graded. Read `question.md`, do the work, and submit:

```bash
astrona run --git ssh://git@github.com/astrona-io/ATS100.git -c sections/<section>/<module>/labs/lab-01
astrona submit -c sections/<section>/<module>/labs/lab-01
astrona destroy <name>
```

Each lab grades the **final state** with independent checks, and several of
them deliberately reject the plausible-but-wrong fix (reinstalling Harbor,
turning TLS off, signing the CLI in as `admin`, changing a user's password to
fit a stale credential).
