# Overview: Upgrading, Rolling Back And Migrating Harbor (Playground)

This is a **playground**, not a lab. It starts a fresh cluster, installs Harbor with the `harbor-helm` chart, starts the workstation pod, and copies one image into Harbor. There is no task, no `astrona submit` and no pass or fail.

## What's in the box

- A single-node `kind` Kubernetes cluster. `kubectl` is already pointed at it.
- **Helm 3.22.1** on your machine, in `/usr/local/bin` or `~/.local/bin`, with the `harbor` chart repository added.
- **Harbor 2.15.4**, the Helm release `harbor` in the namespace `harbor`, chart 1.19.4, at `https://harbor.localtest.me:8443`. The administrator is `admin` with the lab-only password `Harbor12345`. The certificate comes from the Secret `harbor-tls` (`certSource: secret`), signed by a lab certificate authority, Harbor Lab CA, so it stays the same across every `helm upgrade`.
- The project `inventory` with `inventory/podinfo:6.15.0`.
- The **workstation** pod in the namespace `workstation`, with `harbor`, `regctl`, `oras`, `cosign`, `curl` and `jq`, trusting Harbor's CA.

## Helpers

Paste these once in each new terminal. `ws` runs a command in the workstation. `token_realm` prints the realm the registry sends clients to.

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
token_realm() {
  ws curl -sSI https://harbor.localtest.me:8443/v2/ | grep -i '^www-authenticate:'
}
```

## Practice tasks

- Run `helm -n harbor history harbor` and `helm -n harbor get values harbor`. Note the revision number.
- Run `helm upgrade harbor harbor/harbor --version 1.19.4 -n harbor --reuse-values --set logLevel=debug --dry-run` and read what it would change before you apply it.
- Upgrade with `--set registry.registry.image.tag=v0.0.0-missing --wait --timeout 3m`, watch the pods with `kubectl -n harbor get pods`, then roll back with `helm -n harbor rollback harbor <revision>`.
- Compare the revision numbers before and after the rollback and read the `description` column of the history.
- Run `helm search repo harbor/harbor --versions | head` and find the chart version that installs the next Harbor patch release.
