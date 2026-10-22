# Section 010: Harbor Architecture And OCI Artifacts

Harbor is a container registry: a server that stores container images and other artifacts and serves them over HTTP. It is not one program. A running Harbor is about eight components, and each one has its own job. When something fails, the first question is always which component failed, so this section starts by taking a running Harbor apart.

You will see every component as a Kubernetes workload, follow one push from the client to storage, and read Harbor's health API. Then you will store more than images: a Helm chart and a plain file, both as Open Container Initiative (OCI) artifacts, and you will see why a digest names an artifact more exactly than a tag.

**Topic covered:** Harbor architecture and OCI artifacts

## What you will learn

- The Harbor components (`core`, `registry`, `portal`, `jobservice`, `trivy`, `database`, `redis`, `nginx`) and what each one does.
- How a push travels from the client through the proxy and the token service to the registry.
- Reading `/api/v2.0/health` and `/api/v2.0/systeminfo`.
- Creating a project with the REST API and copying an image into it with `regctl`.
- Storing a Helm chart and a plain file as OCI artifacts with `regctl` and `oras`.
- Tags against digests, and how to prove two copies are the same artifact.

## The learning path

Work through the module in order. It has a landing page, three short parts, a graded lab right after the part it tests, and a summary. The landing page starts the module's playground, a cluster with a running Harbor where you can explore freely.

### 1. Find Your Way Around A Running Harbor

The playground holds a fresh Harbor 2.15.4 and a workstation pod with the client tools.

1. The Harbor Components And What They Do
2. Following A Push Through Harbor, followed by the lab **Find And Restart The Broken Harbor Components**
3. Images, Helm Charts And Other OCI Artifacts
4. Summary

## Section capstone: Make Harbor Store Images And Charts Again

The capstone combines the whole module. Two components of Harbor are stopped, the project `inventory` is empty, and the team needs both the podinfo image and its Helm chart in Harbor, byte for byte the same as the source. Work it after the module lab.

Start the capstone:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS100.git -c sections/section-010/capstone/labs/lab-01
```

When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-010/capstone/labs/lab-01
```

When the capstone is done, remove it:

```sh
astrona destroy ats-100-capstone-010
```
