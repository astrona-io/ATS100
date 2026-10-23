# Writing style for this repo

All study text here (course pages, lab docs, READMEs, comments in YAML and
scripts) is for people learning a technical subject, often for a
certification exam. Many of them are not native English speakers and have no
university degree.

## Technical documentation in plain English

This is technical documentation. Say exactly what the system does, with the
real technical terms, in clear and simple English. Never hide a concept
behind a metaphor, a made-up name or a vague word: the reader must learn the
words they will meet in the product, the logs and the exam.

Strict guidelines:

1. Use the correct technical term every time (request, response, pod,
   namespace, Service, sidecar proxy, certificate, mTLS, JWT, listener). The
   first time a term appears in a file, define it in one plain sentence that
   says what it is and what it does. Spell out every acronym on first use.
2. No metaphors or analogies in explanations. Not "the communications
   officer", but "the sidecar proxy (Envoy)"; not "a signal", but "a
   request"; not "the planet", but "the namespace".
3. Simple sentences. Target a Flesch-Kincaid Grade Level of 8 or 9 for the
   prose around the terms. Keep sentences direct; split long sentences into
   two. No corporate buzzwords.
4. Use short paragraphs (max 3-4 sentences per paragraph).
5. Use the active voice ("istiod sends the configuration", not "the
   configuration is sent").

## How this applies to course material

- **Know which file you are in.** A module has a short landing page, a few
  deep-dive parts and a summary page. The landing page is a map: goals, what
  to know first, the order of the parts. The real teaching goes in the parts.
  The summary closes the module. A lab
  has a task, a step-by-step solution and a short intro. Keep each file to its
  job. Do not add "Prerequisite: ... Next: ..." navigation lines to pages;
  the landing page and the course outline already give the order.
- **Keep each part short.** One idea per part, about 5 to 8 minutes of
  reading and at most about 8 command blocks, so a learner can finish it with
  the playground in one sitting of about 15 minutes. Split at a natural seam
  where each half ends with something the learner has seen work. Never split
  only to hit a number. When you split, renumber the files, fix every "Part N"
  reference in the module and `astrona.yaml`.
- **Read like a book, not like a web page.** Each part reads as a chapter of
  a technical book. Open with a short paragraph on the problem it solves and
  why it matters. Link each paragraph to the next with a transition sentence.
  Close with a paragraph that sums up what the reader now knows and the
  question still open, before `## Common pitfalls` and the mission. Write
  explanations as prose; keep bullets for real lists (fields, ordered steps,
  options). Use `##` only when the topic changes and `###` only inside a long
  section, never for a single command. Weave hands-on steps into the text:
  one or two sentences on what to run and why, the command, the real output,
  then a sentence or two on what it shows.
- **The module ends with a summary.** The last page of every module is
  `course-0N-summary.md` with the title `# Summary`: a few short prose
  paragraphs on what the reader learned, organised by idea, optionally with
  one short list of key facts. It names no parts, modules, sections or
  chapters, and has no links, lab table, quiz or commands. Its last line is
  `<!-- astrona:playground:destroy -->` on its own line; the platform turns it
  into the step that removes the playground.
- **Every heading gets an intro.** A `##` section that has `###`
  subsections starts with one to three sentences that say what the section
  is about and why it matters, before the first `###`. Never put a `###`
  directly under a `##`.
- **Every module stands on its own.** Never refer to other sections or
  modules: no "see section 040", "as module 3 showed", "you met this in
  section 000", and no links to pages in another module. If the reader needs
  a fact from elsewhere, state the fact directly in one or two sentences.
  This also goes for parts of the same module: never write "Part 2 shows",
  "from Part 1" or "as in Part 3". Say the fact itself ("the commands below
  need the `scout` `DestinationRule` applied"). This includes the summary.
  The landing page does not have a "Where this fits" section.
- **Write words out in full.** Do not use informal short forms in prose:
  write "communications", "configuration", "repository", "administrator",
  "for example" and "that is", never "comms", "config", "repo", "admin",
  "e.g." or "i.e.". Names in code, commands and file paths stay as they are.
- **Exam terms stay.** The product's own names are what the reader must learn
  (for example a resource kind, a field, a command). Use them as they are and
  define each one in plain technical words the first time it appears in a
  file. Spell out acronyms on first use, with a short plain meaning.
- **The space theme is only for examples.** Space appears in two places and
  nowhere else: the names of the example workloads (the Starfleet: `bridge`,
  `scout`, `shuttle`, `probe`, the `starfleet` and `outpost` namespaces) and
  the short scenario that opens a lab task or a practice exercise (for
  example "the `drifter` in `outpost` must keep reaching the probe"). The
  explanation around an example is plain technical text: write "the
  `shuttle` pod sends a request to the `probe` Service", never "the shuttle
  sends a signal to the probe ship". Do not address the reader as an
  astronaut, and do not use space metaphors (communications officer, mission
  control, badge, airlock, guest list, star chart) for Istio or Kubernetes
  concepts. Titles of pages and labs name the technical task ("Require mTLS
  With PeerAuthentication"), not a space story.
- **Show one real example before the rule.** Start with a concrete case the
  reader can run, then give the general rule.
- **Say which part does the work.** Readers often mix up the parts of a system
  that sit close together. Whenever something happens, say which component
  did it.
- **Never change code to fit the style.** Commands, configuration files, field
  names, resource names, log lines and command output stay exactly as they
  are. They were run and checked on a real system. Never make up command
  output. If you shorten it, say that you did.
- **Prose only.** The grade-level and sentence rules apply to explanations.
  They do not apply to code blocks, tables of field names or reference lists
  (those may stay short and dense).
- **Keep the page furniture the same.** Hands-on steps are part of the prose
  (see "Read like a book"), not boxes or headings of their own. A `> [!TIP]` box is
  only for a real tip: advice the reader can reuse beyond this one step (a
  habit, a shortcut, how to spot a problem, an exam habit). Everything else
  is a normal sentence: notes about the current step ("if the log line is
  old, run it again"), background facts, optional extra steps, and plain
  information. Never a command snippet, never two in a row, and most pages
  need zero or one tip. Each part ends with a
  `## Common pitfalls` `> [!WARNING]` block for that part only. Use a Mermaid
  diagram for a flow, an order or a state change, keep it under about 12
  boxes, and follow it with one sentence that says what it shows.
- **Labs come right after the part they practise.** Do not collect all
  graded labs at the end of a module. In `astrona.yaml`, put each lab (its
  `question.md` reading and the `lab` entry) right after the reading part it
  tests. If a part teaches a gradeable skill and no lab covers it, create a
  new lab. That part then ends with a `## Your mission: <lab title>` section:
  one sentence on what the reader can now do, one on what the mission asks,
  then pause the playground (`astrona stop <playground name>`), the
  `astrona run` and `astrona submit` commands, and finally
  `astrona destroy <lab name>` plus `astrona start <playground name>`.
- **Renew the playground before hands-on work.** Every reading part that
  runs commands has `<!-- astrona:playground:renew -->` exactly once, on its
  own line, right before the first hands-on step (the first "Save this as"
  or the first command block), so the playground timer is reset before the
  learner needs the playground. Not on landing pages (they carry
  `<!-- astrona:playground -->`), summary pages (they carry
  `<!-- astrona:playground:destroy -->`) or pages without commands.
- **Mermaid without HTML.** The platform renders Mermaid with HTML labels
  switched off, so `<br/>` and any other HTML tag break the drawing. Rules:
  - One line per box, no `<br/>`, no HTML. Keep the box to the thing's name
    (`"scout-v2"`, `"istiod"`, `"Service: scout"`).
  - Put the logic on the arrows: `E -->|"version: v2"| P2`,
    `I -->|"CDS"| C`, `A -->|"end-user: jason"| B`. Keep edge labels short.
  - Quote every label. Prefer `flowchart TB`; use `LR` only for a short chain.
  - Sequence diagrams: short participant aliases (`participant S as shuttle`)
    and short message text.
  - Anything longer (cluster names, full hostnames) goes in the sentence under
    the diagram.
- **Every course starts with an Introduction.** It lives in `sections/intro/`
  and is the first entry in `astrona.yaml` (`id: module-intro`, title
  "Introduction"). It has exactly these four pages, in this order:
  - `README.md`, `# Introduction`: what the introduction covers and its three
    pages, named in prose (no links), ending with the topic the course starts
    with.
  - `course-01-welcome.md`, `# Welcome To The Course`: who the course is for,
    the exam domain and what the reader can do at the end, the words the
    course uses, the example app, how the course is laid out and how to read
    a page.
  - `course-02-get-your-machine-ready.md`, `# Get Your Machine Ready`: the
    tools to install, the `astrona` commands used every day, and what to do
    when a start goes wrong.
  - `course-03-how-this-course-is-made.md`, `# How This Course Is Made`: how
    content is written and checked, the maintainers, how to report a mistake,
    and the license.
  The Introduction teaches no product content and has no playground, labs or
  summary. Its only links are the repository's contributors page, issues
  page and license.
- **No links to other course files.** A course page (every reading listed in
  `astrona.yaml`, the playground guide `docs/overview.md`, and a lab's
  `question.md` and `solution.md`) never links to or points the reader at
  another page or file of the repository: no links to parts, summaries,
  labs, `question.md`, other modules, sections or the Introduction, and no
  "see `practice.md`" or "open `config.yaml`". The platform shows the pages in
  the order of `astrona.yaml`, so a link only adds a second, often wrong,
  path. Name a thing in plain words when the reader needs it ("the task is on
  the next page"), and state a fact on the page itself instead of sending the
  reader somewhere else. Repository files for authors (the root `README.md`,
  a lab's or playground's `README.md`) may link.
- **No links to outside sources.** Course pages, labs and playground docs do
  not link to or point at outside websites (the one exception is the
  `resources` field of a lab entry in `astrona.yaml`) (official docs, GitHub, blogs,
  RFCs), and they have no "Reference" or "Official docs" lists. Everything the
  reader needs is explained on the page itself. Not affected: addresses the
  reader actually uses in a command or browser (`http://127.0.0.1:9080`,
  `curl https://httpbin.org`), and the Introduction's contributors and
  "report a mistake" links.
- **Configuration goes to a file first.** Whenever the reader should apply
  YAML (course parts, playground docs, labs), use three separate steps:
  1. "Save this as `virtualservice-scout.yaml`:" followed by a plain
     ` ```yaml ` block with only the YAML. No `cat > file <<'EOF'`, no
     `kubectl apply -f - <<EOF`, no shell around it.
  2. "Apply it:" followed by a ` ```sh ` block with only
     `kubectl apply -f virtualservice-scout.yaml`.
  3. "Then check the result:" followed by the check commands, if any.
  The file name says the kind and the object. If a value must come from the
  reader's cluster (an IP address), use a placeholder like `<PARTNER>` in the
  YAML and say how to get the value (`echo $PARTNER`); never put shell
  variables inside YAML. Apply an object the first time its YAML appears; do
  not show it once "to read" and paste it again later. Never tell the reader
  to apply something from the playground's `examples/` folder: they start the
  playground with `astrona run`, so that folder is not on their machine.
- **Helpers have readable names.** Shell helper functions and variables use
  names that say what they do (`check_route`, `count_versions`,
  `$SERVICE_URL`), never single letters.


## About this repo (ATS100 only)

Everything above is general and can be copied to other course repositories. This
section is only true for this one.

### What the student is trying to learn

- **The goal:** master the **Architecture, Installation & Harbor CLI Basics**
  domain of the **Harbor** training path (`ATP020`). It is 10% of the path.
  There is no official Harbor certification exam; the path's domains and
  weights are Astrona's own, set in `ATP020/path.yaml`.
- **What the domain really tests:** installing Harbor, knowing which component
  does what, and using it from the command line: push and pull an artifact,
  find which component failed, and sign the `harbor` CLI in with contexts.
  Every explanation should lead to a command they can run, and every fix
  should be proved with an artifact that pushes or pulls, or a component that
  becomes healthy.
- **The three topics:** Harbor's architecture and OCI artifacts, installing
  Harbor (Helm on Kubernetes, and the online/offline installer with Docker
  Compose described in prose), and the `harbor` command-line tool.
- **The sections:**

  | Section | Title | Topic |
  | --- | --- | --- |
  | 010 | Harbor Architecture And OCI Artifacts | Architecture |
  | 020 | Installing Harbor With Helm And TLS | Installation |
  | 030 | The Harbor Command-Line Tool | Harbor CLI |

- **The versions:** **Harbor v2.15.4** installed with the `harbor-helm` chart
  **1.19.4** (`appVersion` 2.15.4) and Helm **3.22.1**, on a single-node
  `kind` cluster; the **`harbor` CLI v0.0.27**; `cosign` 3.1.4, `oras` 1.3.5
  and `regctl` 0.11.7 as clients. The Harbor documentation set is 2.15.0;
  2.15.4 is the latest patch of that line. Do not teach fields, flags or output
  from other versions without saying so.
- **The main sources:** the Harbor documentation,
  <https://goharbor.io/docs/2.15.0/>, and the Harbor CLI documentation,
  <https://goharbor.io/cli-docs/> (command pages are generated from the
  `doc/cli-docs/` folder of `goharbor/harbor-cli`; read them there for exact
  flags). Check every page against them.

### Status: built, not yet run

The first version of this repository was written from the Harbor 2.15
documentation **without a live run**. No playground or lab has been started,
and no `astrona test` has passed yet. Until a maintainer runs them:

- Pages describe results in words. Do not add `text` output blocks until the
  output comes from a real run, and then paste it exactly.
- Treat every lab as unverified. Run `astrona validate` and `astrona test` on
  each one, one cluster at a time, before the course goes past `maturity:
  draft`.
- Remove this subsection when every lab has passed `astrona test`.

The `harbor` CLI is young (`v0.0.x`): its flags change between releases. Check
every command against `harbor <command> --help` of v0.0.27 on the first run.

### Terms, not metaphors

| Term | First-use definition (example wording) |
| --- | --- |
| Registry | A server that stores container images and other OCI artifacts and serves them over HTTP |
| OCI artifact | Anything stored with the Open Container Initiative (OCI) distribution format: an image, a Helm chart, a signature, an SBOM, a WebAssembly module |
| Repository / tag / digest | A named collection of artifacts / a movable name for one artifact / the SHA-256 hash that identifies one artifact exactly |
| Project | Harbor's unit of access control and quota; every repository lives in one project |
| `core` | Harbor's API server: authentication, projects, policies, and the token service for the registry |
| `registry` | The CNCF Distribution registry that stores the image layers and manifests |
| `portal` | The web user interface |
| `jobservice` | Runs background jobs: replication, scanning, garbage collection, retention, webhooks |
| `trivy` (adapter) | The scanner Harbor runs to find vulnerabilities and build SBOMs |
| `database` / `redis` | PostgreSQL holds Harbor's data; Redis holds the job queue and caches |
| `nginx` (proxy) | The entry point in front of `core`, `portal` and `registry` when Harbor is not exposed through an ingress |
| `harbor` CLI | The Harbor command-line tool (`goharbor/harbor-cli`); it calls the Harbor REST API v2.0 |
| Credential / context | A saved Harbor server address, user name and encrypted password in the CLI configuration file |
| Robot account | A non-human Harbor account with a token and a limited set of permissions |

### The example workloads

| Name | What it is |
| --- | --- |
| Harbor (namespace `harbor`, Helm release `harbor`) | Harbor 2.15.4. Service `harbor`, HTTPS on port `8443`, HTTP on `8080` (redirects to HTTPS). TLS certificate generated by the chart for `harbor.localtest.me`. No persistence: an `emptyDir` per component |
| Administrator `admin` | Password `Harbor12345`, the chart default. Lab-only credentials; say so when a page uses them |
| `workstation` (namespace `workstation`) | `alpine:3.22` with `harbor`, `cosign`, `oras`, `regctl`, `curl` and `jq`, and Harbor's CA in the system trust store. Every Harbor command on a page runs here |
| Project `inventory` | The example project. Repositories `inventory/podinfo` (copied from `ghcr.io/stefanprodan/podinfo:6.15.0`) and `inventory/charts/podinfo` |

Pages run tools through a helper, defined once per page that needs it:

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws harbor --help
```

### Environment facts the text must respect

- **The `harbor` CLI v0.0.27 without a terminal (seen on a live run,
  2026-10-23).** Every page command runs through `kubectl exec -i` with no
  terminal, so any command that falls back to an interactive form fails
  (`huh: could not open a new TTY`, or `log.Fatal`). Rules from the v0.0.27
  source: `harbor login --password-stdin` reads only from a terminal (a pipe
  fails with `inappropriate ioctl for device`; upstream issue #943 is
  wontfix), so pages pass the lab-only password with `-p`, and scripts never
  sign in (sign in once, then `harbor context switch`). `harbor project
  create` needs a name and `--storage-limit` (`-1` is no quota). `harbor
  project member create` needs `--username` and `--roleid` (`--role` is
  ignored); group members cannot be added without the form, so use
  `POST /api/v2.0/projects/<project>/members` with `member_group`.
- **Harbor images are amd64 only (seen on a live run, 2026-10-23).** On an
  arm64 machine (Apple silicon) every `goharbor/*` image runs under
  emulation. The bundled Valkey (Redis) crashes there with a segmentation
  fault, so every values file replaces it with the multi-architecture
  `docker.io/valkey/valkey:8.1.10-alpine` (`redis.internal.image`). Keep
  that override in every new values file; the other components work under
  emulation. Upgrades must keep it too: use `--reuse-values` or a values
  file that contains it.
- **One address everywhere: `https://harbor.localtest.me:8443`.** Inside the
  cluster a CoreDNS `rewrite stop` block (with the answer name rewritten back)
  sends the name to `harbor.harbor.svc.cluster.local`. On the reader's machine,
  `kubectl -n harbor port-forward svc/harbor 8443:8443` makes the web portal
  answer there; the browser warns about the lab certificate. Copy the CoreDNS
  block from `sections/section-010/module-01/playground/bootstrap/prepare.sh`;
  never the one-line `rewrite name` form.
- **The workstation trusts Harbor.** It downloads Harbor's CA from
  `/api/v2.0/systeminfo/getcert` at start and runs `update-ca-certificates`.
  Never teach `--insecure` or `--insecure-registry` for this environment.
- **No image pulls by the kind node from Harbor.** The node does not use
  CoreDNS and does not trust the CA. "Block a vulnerable or unsigned image" is
  shown with Harbor's own project settings, which refuse the pull, tested from
  the workstation with `regctl` or `oras`.
- **Docker Compose installs are prose.** The online and offline installers
  (`harbor.yml`, `./install.sh`, `--with-trivy`) are explained with real
  configuration, but no lab runs Docker Compose; every environment is Harbor
  on `kind` through Helm.
- **Internet is needed:** the chart images from Docker Hub (`goharbor/*`),
  the Trivy vulnerability database from `ghcr.io`, the client tools from
  GitHub, and `ghcr.io/stefanprodan/podinfo` as example content.
- **Harbor is big.** Allow about 4 GiB of memory per environment and up to 15
  minutes for the first start.
- **Many environments start broken on purpose.** A lab seeds a fault (a
  component scaled to zero, a wrong `externalURL`, a stale CLI credential).
  The fault is the material. Never "fix" it in the bootstrap.

### Where things are in this repo

The layout is the same as every Astrona course: `astrona.yaml`, `README.md`,
`sections/intro/`, `sections/section-0N0/README.md`, module pages
(`course.md`, `course-0N-*.md`), `playground/` (`config.yaml`,
`bootstrap/prepare.sh`, `manifests/harbor-values.yaml`,
`manifests/lab-start.yaml`, `docs/overview.md`), labs (`config.yaml`,
`README.md`, `prerequisites.md`, `question.md`, `solution.md`,
`bootstrap/01-install-harbor.sh`, `bootstrap/02-seed-state.sh`, `manifests/`,
`solution/apply.sh`, `testing/wait-for-harbor.sh`, `validation/validate-*.sh`)
and one capstone per section.

### Lab metadata in `astrona.yaml`

`training:` block: id `ATS100`, domain `Architecture, Installation & Harbor
CLI Basics`, weight `10`. Lab entries carry `title`, `path`, `difficulty`,
`estimated_duration`, `topic`, `task_kind`, `tags`, `learning_goals`,
`resources`, in that order, as in ATS016.

- `topic`: exactly one of `architecture`, `artifacts`, `installation`, `tls`,
  `cli`.
- `task_kind`: `build`, `troubleshooting` or `migration`.
- `tags`: 4 to 8, only from this list: `core`, `registry`, `jobservice`,
  `portal`, `trivy`, `database`, `redis`, `nginx`, `oci-artifacts`,
  `helm-chart`, `oras`, `regctl`, `digest`, `harbor-helm`, `values-yaml`,
  `external-url`, `tls-certificate`, `ca-trust`, `harbor-yml`,
  `docker-compose`, `harbor-cli`, `cli-login`, `cli-context`, `cli-config`,
  `harbor-api`, `health`.
- `resources`: 1 to 4 pages on `goharbor.io`. The only place outside links
  are allowed.

### Running things

```bash
astrona run --git ssh://git@github.com/astrona-io/ATS100.git -c sections/section-010/module-01/playground
astrona destroy ats-100-playground-010-01
astrona run --git ssh://git@github.com/astrona-io/ATS100.git -c sections/section-010/module-01/labs/lab-01
astrona submit -c sections/section-010/module-01/labs/lab-01
astrona destroy ats-100-lab-010-01
astrona test -c sections/section-010/module-01/labs/lab-01   # authors
```

Names: `ats-100-playground-<section>-<module>`, `ats-100-lab-<section>-<module>`,
`ats-100-capstone-<section>`. Graders check **behaviour** (an artifact pushes
or pulls, the CLI reaches the right server, `/api/v2.0/health` reports every
component healthy) and reject the plausible but wrong fix (turning TLS off,
using `--insecure`, reinstalling Harbor from scratch, changing the admin
password to make a login work). A lab's `question.md` and `solution.md` must
match what its `validation/` scripts check.

### Where to find trusted sources

- **Architecture and installation:**
  [Harbor installation and configuration](https://goharbor.io/docs/2.15.0/install-config/),
  [Deploying Harbor with high availability via Helm](https://goharbor.io/docs/2.15.0/install-config/harbor-ha-helm/),
  [configure HTTPS](https://goharbor.io/docs/2.15.0/install-config/configure-https/),
  [configure the Harbor YML file](https://goharbor.io/docs/2.15.0/install-config/configure-yml-file/)
- **Working with artifacts:**
  [working with projects](https://goharbor.io/docs/2.15.0/working-with-projects/)
- **CLI:** [Harbor CLI documentation](https://goharbor.io/cli-docs/),
  `doc/cli-docs/` in `goharbor/harbor-cli`
- **API:** the Swagger file served by Harbor at `/devcenter-api-2.0`
- **The landscape:** <https://www.cncf.io/projects/harbor/> (graduated).
