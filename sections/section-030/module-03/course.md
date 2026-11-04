# Script The Harbor CLI

A cleanup that you run by hand once will be needed again next month. A command that works in your terminal fails in a pipeline because it asks a question, draws a table or uses another saved credential. Scripting the `harbor` command-line tool (CLI) is about making each command predictable: no prompts, data as output, and an exit code the script can test.

This module uses the `harbor` CLI **v0.0.27**, whose flags can change between versions. It builds on signing in, contexts and the management commands.

The module has four parts. **Commands That Never Ask** removes prompts and reads exit codes. **Loops, jq And Safe Bulk Changes** selects objects from JSON and changes them in a loop; a graded lab follows it. **Signing In From A Pipeline** covers credentials without a terminal. **Installing, Pinning And Troubleshooting** keeps the tool and its version under control.

## Learning objectives

After this module you can:

- Write commands that run without a terminal and without questions.
- Read the exit code of a `harbor` command and stop a script on failure.
- Select fields from `-o json` output with `jq`, using the `Payload` array.
- Print the commands of a bulk change before running them.
- Sign in from a script without leaving the password in the shell history.
- Pin the CLI version and use `-v` to find out why a command failed.

## Before you start

You should be able to sign in with the CLI, switch contexts, and list projects, repositories and artifacts. You should know basic shell loops and `jq`.

Your playground is a single-node `kind` cluster with **Harbor 2.15.4** at `https://harbor.localtest.me:8443`. The project `inventory` holds `podinfo:6.14.1`, `podinfo:6.15.0` and the Helm chart `charts/podinfo:6.15.0`. The users are `admin` / `Harbor12345`, `inventory-dev` / `Inventory-dev-123` and `inventory-reader` / `Inventory-read-123`, all lab-only. The CLI runs in the **workstation** pod through two helpers:

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
wst() { kubectl -n workstation exec -it deploy/workstation -- "$@"; }
```

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
