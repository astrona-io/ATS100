# Overview: The OCI Distribution Model (Playground)

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

- Create the project `inventory`, copy `ghcr.io/stefanprodan/podinfo:6.15.0` into it, and read the manifest with `ws regctl manifest get harbor.localtest.me:8443/inventory/podinfo:6.15.0 --format raw-body | ws jq`. Find out whether it is an image index or a single image manifest.
- Take one child digest from the index and read that manifest and its config blob.
- Attach a text file to the image with `oras attach` and list it with `oras discover`.
- Pull the attached file back with `oras pull` and compare its content.
- Read the artifact with the REST API and find its `references` and `accessories` fields.
