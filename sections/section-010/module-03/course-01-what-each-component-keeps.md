# What Each Component Keeps

Harbor splits its data by purpose. Records go in a database, image layers go in storage, and short-lived work goes in a queue. Because the split follows the component, the same split tells you what each pod restart can cost.

## Look at the workloads and volumes

<!-- astrona:playground:renew -->

```sh
kubectl -n harbor get statefulsets,deployments
kubectl -n harbor get pvc
```

The chart runs `harbor-database`, `harbor-redis` and `harbor-trivy` as StatefulSets, because they keep data on a volume of their own. `harbor-core`, `harbor-portal`, `harbor-registry` and `harbor-jobservice` are Deployments. The claim list shows one claim for each component that stores files: the database, the registry, the job service, Redis and Trivy.

## What each one keeps

| Component | What it keeps | Lost with the pod? |
| --- | --- | --- |
| `database` | Users, projects, repositories, artifact records, tags, policies, scan results (PostgreSQL) | No, it is on a volume |
| `registry` | The blobs and manifests of every artifact | No, it is on a volume (or external storage) |
| `redis` | The job queue, caches and sessions | The data is rebuilt, but running jobs can be lost |
| `jobservice` | Job logs and the state of running jobs | Logs are on a volume |
| `trivy` | The vulnerability database and scan cache | Downloaded again on start |
| `core`, `portal` | Nothing | Nothing |

The database and the registry storage are the two that must never be lost. The database says what exists, and the registry storage holds the bytes. One without the other is useless: records without blobs cannot be pulled, and blobs without records cannot be found.

## Check which volume a component uses

```sh
kubectl -n harbor get pod harbor-database-0 -o jsonpath='{.spec.volumes[*].persistentVolumeClaim.claimName}'
```

The command prints the claim of the database pod. The claim keeps its name when the pod is replaced, which is why a restarted database finds its data again.

## Common pitfalls

> [!WARNING]
> - **Assuming Harbor keeps images in the database.** The database keeps records; the blobs are in the registry storage.
> - **Deleting a PersistentVolumeClaim to "reset" a pod.** The data is gone with the claim. Delete the pod instead.
> - **Treating `core` and `portal` as stateful.** They keep no data, and a restart is safe.
> - **Forgetting that storage can be external.** With S3 or another backend the blobs are not on a claim at all.
