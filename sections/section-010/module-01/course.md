# Find Your Way Around A Running Harbor

A push to Harbor fails with an error that names no component. The pods in the namespace `harbor` all look alike, and their names do not say which one handles your request. Before you can fix anything in Harbor, you need a map: which component does what, and in which order a request passes through them.

Harbor is a container registry: a server that stores container images and other artifacts and serves them over HTTP. Harbor adds projects, users, scanning and replication on top of a plain registry, and it does each of these jobs in a separate component. This module draws that map, then uses it.

The module has three parts. **The Harbor Components And What They Do** names every component and finds it in the cluster. **Following A Push Through Harbor** sends one push through Harbor, step by step, and shows how the health API tells you which component is down; a graded lab follows it. **Images, Helm Charts And Other OCI Artifacts** stores a Helm chart and a plain file next to an image, and shows why a digest is the exact name of an artifact.

## Learning objectives

After this module you can:

- Name the Harbor components and say what each one does.
- Find each component's Deployment or StatefulSet in the namespace `harbor`.
- Describe the path of a push: client, `nginx`, `core` and its token service, `registry`.
- Read `/api/v2.0/health` and say which component is unhealthy.
- Create a project with the Harbor REST API.
- Copy an image and a Helm chart into Harbor with `regctl`, and push a file with `oras`.
- Explain the difference between a tag and a digest, and compare two artifacts by digest.

## Before you start

You need Kubernetes basics: namespaces, Deployments, StatefulSets, Services and the commands `kubectl get`, `kubectl describe`, `kubectl scale` and `kubectl exec`. You should know what a container image is and what pushing and pulling an image means. You do not need to know Harbor.

Your playground is a single-node `kind` cluster with **Harbor 2.15.4** in the namespace `harbor`, installed with the `harbor-helm` chart. Harbor answers at `https://harbor.localtest.me:8443`. The administrator is `admin` with the lab-only password `Harbor12345`.

Every Harbor command runs in the **workstation** pod in the namespace `workstation`. It has the client tools `harbor`, `regctl`, `oras`, `cosign`, `curl` and `jq`, and it already trusts Harbor's certificate authority (CA). The pages run commands there through a short helper:

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
```

The first start takes several minutes, because Harbor pulls many images. Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
