# Solution: Restore Harbor After Its Database Stopped

Work the task yourself first. Running `astrona submit -c sections/section-010/module-03/labs/lab-01` after a step tells you which checks pass.

## Step 1: Find the stopped component

```sh
kubectl -n harbor get statefulsets,deployments,pods
kubectl -n workstation exec -i deploy/workstation -- curl -s https://harbor.localtest.me:8443/api/v2.0/health
```

The StatefulSet `harbor-database` shows `0/0`, and the health API reports the database as not healthy or does not answer. Harbor keeps users, projects and artifact records in the database, so `core` cannot work without it.

## Step 2: Start it again

```sh
kubectl -n harbor scale statefulset/harbor-database --replicas=1
kubectl -n harbor rollout status statefulset/harbor-database
```

The pod `harbor-database-0` starts and attaches the same volume as before, so the data is still there. If `core` reports an error, wait for it to reconnect or look at `kubectl -n harbor logs deploy/harbor-core`.

## Step 3: Check the result

```sh
kubectl -n workstation exec -i deploy/workstation -- curl -s https://harbor.localtest.me:8443/api/v2.0/health
kubectl -n workstation exec -i deploy/workstation -- regctl image digest harbor.localtest.me:8443/inventory/podinfo:6.15.0
```

Every component is healthy and the digest is the one recorded at the start.

## Step 4: Submit

```sh
astrona submit -c sections/section-010/module-03/labs/lab-01
```

## Why the shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| `helm uninstall` and install again | The release is replaced and the check on the Helm revision fails |
| Deleting the PersistentVolumeClaim of the database | Users, projects and artifact records are lost |
| Restarting only `harbor-core` | `core` still cannot reach a database that is not running |
