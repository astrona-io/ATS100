# Overview: Work With Harbor From The Command Line (Playground)

This is a **playground**, not a lab. It starts a fresh cluster, installs Harbor and the workstation pod, and fills Harbor with some content and users. There is no task, no `astrona submit` and no pass or fail.

## What's in the box

- A single-node `kind` Kubernetes cluster. `kubectl` is already pointed at it.
- **Harbor 2.15.4** at `https://harbor.localtest.me:8443`.
- The project `inventory` with `podinfo:6.14.1`, `podinfo:6.15.0` and the Helm chart `charts/podinfo:6.15.0`.
- Three users, all with lab-only passwords: `admin` / `Harbor12345` (system administrator), `inventory-dev` / `Inventory-dev-123` (Developer in `inventory`) and `inventory-reader` / `Inventory-read-123` (Guest in `inventory`).
- The **workstation** pod in the namespace `workstation`, with the `harbor` CLI v0.0.27, `regctl`, `oras`, `cosign`, `curl` and `jq`, trusting Harbor's CA. The CLI is not signed in yet.

## Helpers

Paste these once in each new terminal. `ws` runs a command in the workstation. `current_context` prints the user and server of the CLI's current context.

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
current_context() {
  ws harbor context get credentials.username
  ws harbor context get credentials.serveraddress
}
```

## Practice tasks

- Sign in as all three users with names of your choice, then run `harbor project list` in each context and compare.
- As `inventory-reader`, try `harbor project create test-project` and read the error. Then try it as `admin`.
- Save a context with a wrong password using `--skip-verify-client`, and find the first command that notices.
- Point the CLI at a second configuration file with `HARBOR_CLI_CONFIG=/tmp/other.yaml harbor context list`, and explain why it is empty.
- Build a one-line `jq` filter that prints every tag in `inventory/podinfo` with its push time.
