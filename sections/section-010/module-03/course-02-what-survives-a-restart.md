# What Survives A Restart

A table of what each component keeps is a claim. This part tests it by stopping components and watching Harbor, so you see what each failure looks like before it happens in production.

## Restart a pod that keeps no state

<!-- astrona:playground:renew -->

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
kubectl -n harbor delete pod -l component=portal
kubectl -n harbor rollout status deployment/harbor-portal
ws curl -sS https://harbor.localtest.me:8443/api/v2.0/health
```

Deployments replace a deleted pod. The portal has no state, so the pod comes back and nothing is lost. The health API lists each component with a status.

## Stop the database

```sh
kubectl -n harbor scale statefulset/harbor-database --replicas=0
ws curl -sS https://harbor.localtest.me:8443/api/v2.0/health
```

With no database, `core` cannot read users, projects or artifact records. The health report names the database as not healthy or the request fails, and sign-in and pushes stop. Bring it back:

```sh
kubectl -n harbor scale statefulset/harbor-database --replicas=1
kubectl -n harbor rollout status statefulset/harbor-database
```

The new pod `harbor-database-0` uses the same claim, so all records are back. Scaling to zero stops the pod and keeps the volume; deleting the claim would have removed the data.

## Restart the registry

```sh
kubectl -n harbor delete pod -l component=registry
kubectl -n harbor rollout status deployment/harbor-registry
```

During the restart a pull fails, and a push in progress fails. Blobs on the volume stay, so a new push or pull works afterwards. Failed pushes are repeated by the client.

## Common pitfalls

> [!WARNING]
> - **Scaling a StatefulSet and forgetting to scale it back.** The component stays stopped, and the symptom looks like a Harbor bug.
> - **Restarting `core` to fix a stopped database.** `core` needs the database; start the database first.
> - **Deleting claims while debugging.** Pods are cheap, claims are not.
> - **Judging health by the portal page alone.** The page can load while a component behind it is down. Use the health API.

## Your mission: Restore Harbor After Its Database Stopped

You can now tell which component is missing from a health report and bring a StatefulSet back without touching its data. The graded lab stops Harbor's database and asks you to restore it.

The lab runs in its own cluster, so first pause your playground. Nothing in it is lost:

```sh
astrona stop ats-100-playground-010-03
```

Then start the lab:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS100.git -c sections/section-010/module-03/labs/lab-01
```

The task is on the next page. Solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-010/module-03/labs/lab-01
```

When the lab is done, remove it and start your playground again:

```sh
astrona destroy ats-100-lab-010-03
astrona start ats-100-playground-010-03
```
