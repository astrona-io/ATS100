# Overview: Managing Projects, Members And Artifacts With The Harbor CLI (Playground)

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

- Sign in as `admin` with a context named `admin`, then create the project `shipping` with `harbor project create shipping --storage-limit -1` and read it back with `harbor project view shipping`.
- Add `inventory-reader` to `shipping` with `harbor project member create`, then read the role it received with the REST API. Compare the number you passed with the role you got.
- List the tags of `inventory/podinfo` with `harbor artifact tags list`, add the tag `stable` to the digest of `6.15.0`, and list again.
- Delete the tag `stable` and check with `regctl` that the artifact itself is still there.
- Try `harbor project delete shipping` while the project holds a repository, and read the answer.
