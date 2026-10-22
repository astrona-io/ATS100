# Solution: Make Harbor Store Images And Charts Again

Work the task yourself first. Running `astrona submit -c sections/section-010/capstone/labs/lab-01` after a step tells you which checks pass.

The grader checks four things: every component healthy, the image digest, the chart type and digest, and an unchanged Helm release revision.

## Step 1: Read the health report

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws curl -sS https://harbor.localtest.me:8443/api/v2.0/health | ws jq -r '.components[] | "\(.name) \(.status)"'
```

`redis` and `trivy` are unhealthy. With Redis down, `core` and `jobservice` may report errors too, because they use Redis for caches and the job queue. Fix the root cause first: the components that report themselves down.

## Step 2: Find the stopped workloads

Redis and Trivy keep data, so they run as StatefulSets, not Deployments:

```sh
kubectl -n harbor get statefulsets
```

`harbor-redis` and `harbor-trivy` show `0/0`. Scale them back:

```sh
kubectl -n harbor scale statefulset/harbor-redis --replicas=1
kubectl -n harbor scale statefulset/harbor-trivy --replicas=1
kubectl -n harbor rollout status statefulset/harbor-redis
kubectl -n harbor rollout status statefulset/harbor-trivy
```

Trivy downloads its vulnerability database when it starts, so it can take a few minutes to become ready. Read the health report again until every component shows `healthy`.

## Step 3: Copy the image and the chart

Sign `regctl` in and copy both artifacts. `regctl image copy` copies the manifest and every blob without changes, so the digests stay the same:

```sh
ws regctl registry login harbor.localtest.me:8443 -u admin -p Harbor12345
ws regctl image copy ghcr.io/stefanprodan/podinfo:6.15.0 harbor.localtest.me:8443/inventory/podinfo:6.15.0
ws regctl image copy ghcr.io/stefanprodan/charts/podinfo:6.15.0 harbor.localtest.me:8443/inventory/charts/podinfo:6.15.0
```

## Step 4: Prove each copy by digest

Compare the digests of each source and copy:

```sh
ws regctl image digest ghcr.io/stefanprodan/podinfo:6.15.0
ws regctl image digest harbor.localtest.me:8443/inventory/podinfo:6.15.0
ws regctl image digest ghcr.io/stefanprodan/charts/podinfo:6.15.0
ws regctl image digest harbor.localtest.me:8443/inventory/charts/podinfo:6.15.0
```

Each pair prints the same `sha256:` value. Then check that Harbor recognised the chart. The repository name has a slash, so it is encoded twice:

```sh
ws curl -sS -u admin:Harbor12345 \
  'https://harbor.localtest.me:8443/api/v2.0/projects/inventory/repositories/charts%252Fpodinfo/artifacts/6.15.0' | ws jq -r '.type'
```

The answer is `CHART`.

## Step 5: Submit

```sh
astrona submit -c sections/section-010/capstone/labs/lab-01
```

## Why the obvious shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| Reinstalling Harbor | The components come back, but the release changes, which the task forbids |
| `helm pull` then `helm push` of the chart | Helm packages the chart again; the digest can differ from the source |
| Pulling and pushing the image with a container engine | It can change the manifest (for example, keep only one platform), so the digest no longer matches |
| Fixing only Redis | Pushes work again, but `trivy` stays unhealthy and scanning never runs |
