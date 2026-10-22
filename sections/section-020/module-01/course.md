# Install And Configure Harbor With harbor-helm

A fresh Harbor installation answers in the browser, and yet the first push fails with a network error that names a host nobody has heard of. The cause is almost never in Harbor's code. It is in two values that were set at install time: the external URL, and the TLS certificate.

The `harbor-helm` chart is the supported way to run Harbor on Kubernetes. Helm is the package manager for Kubernetes: it installs a **chart**, a set of templated manifests, with a set of **values** you choose, and it records each change as a numbered **revision** of the **release**. This module reads and changes those values on a running installation.

The module has three parts. **The harbor-helm Values That Matter** walks through the values that decide how Harbor is reached, and shows the token step failing when `externalURL` is wrong; a graded lab follows it. **TLS Certificates And Trust** covers where Harbor's certificate comes from and how a client learns to trust it. **The Docker Compose Installers And harbor.yml** maps the same settings to the installers used on a single virtual machine.

## Learning objectives

After this module you can:

- Read the values of a Harbor release with `helm get values`, and change them with `helm upgrade`.
- Choose an `expose.type` and set `externalURL` to match it.
- Explain how `externalURL` becomes the token realm the registry sends to clients.
- Choose a TLS certificate source: `auto`, `secret` or `none`.
- Make a client trust Harbor's certificate authority, and set `caSecretName` so Harbor offers it for download.
- Write the `hostname`, `https` and `harbor_admin_password` settings of `harbor.yml`, and run `./install.sh --with-trivy`.

## Before you start

You need Kubernetes basics and the ability to edit YAML. You should know that Harbor's entry point is `nginx`, that `core` signs the tokens the `registry` accepts, and that the registry sends clients to the token service with the `WWW-Authenticate` header. You do not need to know Helm well; each command is explained.

Your playground is a single-node `kind` cluster with **Harbor 2.15.4**, installed as the Helm release `harbor` in the namespace `harbor` with chart version 1.19.4. Helm 3.22.1 is on your machine, in `/usr/local/bin` or `~/.local/bin`. Harbor answers at `https://harbor.localtest.me:8443`; the administrator is `admin` with the lab-only password `Harbor12345`. The project `inventory` holds `inventory/podinfo:6.15.0`.

Every Harbor command runs in the **workstation** pod, which trusts Harbor's certificate authority:

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
```

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
