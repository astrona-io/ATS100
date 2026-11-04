# Overview: From harbor.yml To Helm Values (Playground)

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

- Write a small `harbor.yml` in the workstation pod with `external_url`, `log.level` and `jobservice.max_job_workers`, and write the matching Helm values by hand.
- Run `helm show values harbor/harbor --version 1.19.4` and find the chart name of each setting.
- Preview your values with `helm upgrade --reuse-values -f myvalues.yaml --dry-run` and check that `externalURL` and the certificate settings did not change.
- Apply the file, then compare `helm get values harbor` with the file.
- Find a `harbor.yml` setting that has no direct chart value, and decide what replaces it in Kubernetes.
