# Commands That Never Ask

A script has no keyboard. Any command that waits for an answer stops the script forever, and any command that draws a table gives the script text it cannot read reliably. This part finds the commands and flags that avoid both.

## Give every argument

Some commands ask for missing arguments in an interactive form. `harbor artifact list` with no argument asks for the project and the repository; `harbor project create` without `--storage-limit` stops with an error when there is no terminal. In a script, always give the full argument:

<!-- astrona:playground:renew -->

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws harbor login https://harbor.localtest.me:8443 --username admin \
  --password Harbor12345 --context-name admin --skip-verify-client
ws harbor artifact list inventory/podinfo -o json | head -c 200
```

`ws` has no terminal, which is how a pipeline runs. The command prints JSON because of `-o json`.

## Output as data

The global flag `-o` (`--output-format`) selects `json`, `yaml` or `csv`. A table is drawn only on a terminal, so `ws harbor project list` without `-o` has nothing readable to give a script. List commands wrap their items in `Payload`:

```sh
ws sh -c 'harbor project list -o json | jq -r ".Payload[].name"'
```

The output is one project name per line. This is the shape that loops and other tools can use.

## Exit codes

A script decides what to do next from the exit code: `0` is success and anything else is failure. Check it directly after the command:

```sh
ws harbor project view does-not-exist; echo "exit code: $?"
```

The command prints an error and the exit code is not `0`. In a script, `set -e`, or `if ! command; then ...; fi`, stops or branches on this. Do not rely on text in the output, because error messages can change between versions.

## Common pitfalls

> [!WARNING]
> - **Calling a command with missing arguments.** It may wait for input that never comes. Pass every argument.
> - **Parsing the table.** Use `-o json`.
> - **Ignoring the exit code.** A failed delete looks like success if the script goes on.
> - **Using `-it` in a pipeline.** There is no terminal; use `-i` only.
