# Overview: Find Your Way Around A Running Harbor (Playground)

This is a **playground**, not a lab. It starts a fresh cluster, installs Harbor and the workstation pod, and then waits. There is no task, no `astrona submit` and no pass or fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` Kubernetes cluster. `kubectl` is already pointed at it.
- **Harbor 2.15.4** in the namespace `harbor`, installed with the `harbor-helm` chart 1.19.4. It answers at `https://harbor.localtest.me:8443`. The administrator is `admin` with the lab-only password `Harbor12345`. Nothing is persisted: deleting a pod of `database` or `registry` loses its data.
- The **workstation** pod in the namespace `workstation`, with `harbor`, `regctl`, `oras`, `cosign`, `curl` and `jq`, and Harbor's certificate authority already trusted.
- No projects yet. Create the project `inventory` before you push.

## Helpers

Paste these once in each new terminal. `ws` runs a command in the workstation. `harbor_health` prints one line per component with its status.

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
harbor_health() {
  ws curl -sS https://harbor.localtest.me:8443/api/v2.0/health | ws jq -r '.components[] | "\(.name) \(.status)"'
}
```

Use them like this: `ws regctl version`, `harbor_health`.

To open the web portal, run `kubectl -n harbor port-forward svc/harbor 8443:8443` in a second terminal and open `https://harbor.localtest.me:8443`. Your browser warns about the lab certificate.

## Practice tasks

- Scale each Deployment in `harbor` to zero in turn, read `harbor_health`, and note which components the report marks as unhealthy. Scale it back to one before you try the next.
- Stop `harbor-jobservice` and push an image. Note that the push works, and think about which features would stop working.
- Copy `ghcr.io/stefanprodan/podinfo:6.14.1` into `inventory/podinfo` and compare its digest with `6.15.0`.
- Push two different files with `oras` under the same tag, one after the other, and read the digest each time. Then explain what happened to the first artifact.
- Read `/api/v2.0/systeminfo` and find the external URL. Then look for the same value in `helm -n harbor get values harbor`.
