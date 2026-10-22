# Work With Harbor From The Command Line

A command that worked yesterday now answers `401 Unauthorized`, or lists the projects of a different Harbor. The command did not change; the credential behind it did. The `harbor` command-line tool (CLI) keeps a list of saved credentials, and knowing which one it uses is the first skill of working with it.

The `harbor` CLI is the official command-line tool of the Harbor project. It calls the Harbor REST API v2.0, the same API the web portal uses, and it is still young: this course uses version **v0.0.27**, and its flags can change between versions. When in doubt, `harbor <command> --help` shows the flags of the version you run.

The module has three parts. **Signing In And Where The CLI Keeps Credentials** signs the CLI in and opens its configuration file. **Contexts For More Than One Server Or User** saves several credentials and switches between them; a graded lab follows it. **Everyday Commands And Output Formats** lists projects, repositories and artifacts, and turns the output into JSON for scripts.

## Learning objectives

After this module you can:

- Sign the CLI in with `harbor login`, and choose the name of the saved credential.
- Find the CLI configuration file and read what each credential holds.
- Explain how the CLI encrypts passwords and where the encryption key comes from.
- List, switch, read, change and remove credentials with `harbor context`, and sign out with `harbor logout`.
- Use `harbor info`, `harbor health`, `harbor project list`, `harbor repo list` and `harbor artifact list`.
- Get JSON, YAML or CSV output with `-o`, and filter it with `jq`.

## Before you start

You should know what a Harbor project is, that every repository lives in one, and that members have roles such as Developer and Guest. You should be comfortable with `kubectl exec` and with reading JSON.

Your playground is a single-node `kind` cluster with **Harbor 2.15.4** at `https://harbor.localtest.me:8443`. The project `inventory` holds `podinfo:6.14.1`, `podinfo:6.15.0` and the Helm chart `charts/podinfo:6.15.0`. There are three users, all with lab-only passwords:

| User | Password | Role in `inventory` |
| --- | --- | --- |
| `admin` | `Harbor12345` | System administrator |
| `inventory-dev` | `Inventory-dev-123` | Developer: can push and pull |
| `inventory-reader` | `Inventory-read-123` | Guest: can only pull and read |

The `harbor` CLI runs in the **workstation** pod, which trusts Harbor's certificate authority. The pages run it through a short helper:

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
```

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
