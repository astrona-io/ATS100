# Prerequisites

Before starting this lab you should be able to:

- Run commands in a pod with `kubectl exec`.
- Sign in to a server with a user name and a password.
- Explain what a Harbor project member is.

## What the environment gives you

The lab environment builds itself before the task begins. It takes several
minutes, because Harbor runs many components:

- A single-node `kind` Kubernetes cluster, with `kubectl` already pointed at it.
- **Harbor 2.15.4** in the namespace `harbor`, installed with the `harbor-helm`
  chart 1.19.4 and **Helm 3.22.1**, which the environment puts in
  `/usr/local/bin` or `~/.local/bin` on your machine.
- Harbor answers at `https://harbor.localtest.me:8443` inside the cluster. The
  administrator is `admin` with the lab-only password `Harbor12345`.
- The **workstation** pod in the namespace `workstation`, with `harbor`,
  `regctl`, `oras`, `cosign`, `curl` and `jq`, and Harbor's certificate
  authority already trusted. Run tools there with
  `kubectl -n workstation exec -i deploy/workstation -- <command>`.

## Working rules

- Everything is graded on the **final state**, so check your result at the end
  and leave the fix in place.
- Change one thing at a time and check again.
- Do not turn TLS off and do not use `--insecure` flags. The workstation
  already trusts Harbor.
