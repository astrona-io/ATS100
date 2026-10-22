# Solution: Find And Restart The Broken Harbor Components

Work the task yourself first. Running `astrona submit -c sections/section-010/module-01/labs/lab-01` after a step tells you which checks pass, without telling you what is left.

The grader checks three things: the health API reports every component healthy, a push to `inventory` succeeds, and the Helm release revision has not changed.

## Step 1: Read the health report

Define the helper and ask `core` how every component is:

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws curl -sS https://harbor.localtest.me:8443/api/v2.0/health | ws jq -r '.components[] | "\(.name) \(.status)"'
```

Two kinds of component show `unhealthy`: `registry` (and with it `registryctl`), and `jobservice`. The portal works because `portal` and `core` are healthy, which is why the team missed the problem.

## Step 2: Find the stopped workloads

Each component is a workload in the namespace `harbor`. List them with their ready counts:

```sh
kubectl -n harbor get deployments,statefulsets
```

`harbor-registry` and `harbor-jobservice` show `0/0` ready: someone scaled them to zero replicas. Nothing is crashing; there are simply no pods. `kubectl -n harbor describe deployment harbor-registry` confirms `Replicas: 0 desired`.

## Step 3: Bring them back

Scale both back to one replica and wait for them:

```sh
kubectl -n harbor scale deployment/harbor-registry --replicas=1
kubectl -n harbor scale deployment/harbor-jobservice --replicas=1
kubectl -n harbor rollout status deployment/harbor-registry
kubectl -n harbor rollout status deployment/harbor-jobservice
```

Do not run `helm upgrade` to get the replicas back. It would work, but it changes the release, and the task forbids it.

## Step 4: Prove the fix

Read the health report again, then push:

```sh
ws curl -sS https://harbor.localtest.me:8443/api/v2.0/health | ws jq -r '.status'
ws regctl registry login harbor.localtest.me:8443 -u admin -p Harbor12345
ws regctl image copy ghcr.io/stefanprodan/podinfo:6.15.0 harbor.localtest.me:8443/inventory/podinfo:6.15.0
```

The overall status is `healthy`, and the copy finishes without an error. If `jobservice` still shows unhealthy, wait half a minute: it needs Redis and a few seconds to register.

## Step 5: Submit

```sh
astrona submit -c sections/section-010/module-01/labs/lab-01
```

## Why the obvious shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| `helm upgrade` or reinstalling Harbor | It brings the pods back, but it changes the release, and a reinstall loses every artifact because nothing is persisted |
| Restarting `core` | `core` is healthy; restarting it changes nothing |
| Fixing only the registry | Pushes work, but scans, replication and retention never run, and the health report stays unhealthy |
