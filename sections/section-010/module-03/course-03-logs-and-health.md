# Reading Logs And Health

When Harbor fails, two sources tell you why: the health API says which component is unhealthy, and the logs of that component say what it saw. This part reads both in a fixed order.

## Start with the health API

<!-- astrona:playground:renew -->

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws sh -c 'curl -sS https://harbor.localtest.me:8443/api/v2.0/health | jq ".components[] | {name, status}"'
```

Each component shows `healthy` or an unhealthy status. The report is built by `core`, so if the API does not answer at all, `core` or the ingress in front of it is the first suspect.

## Then the pods

```sh
kubectl -n harbor get pods
kubectl -n harbor describe pod -l component=core
```

A pod in `CrashLoopBackOff` or `ImagePullBackOff`, or restarts in the list, point at the failing component. `describe` shows the events: failed probes, missing volumes or scheduling problems.

## Then the logs

Harbor components write their logs to standard output, so `kubectl logs` reads them:

```sh
kubectl -n harbor logs deploy/harbor-core --tail=50
kubectl -n harbor logs deploy/harbor-registry --tail=50
kubectl -n harbor logs statefulset/harbor-database --tail=50
```

`core` logs requests and errors, such as a failed database connection. `registry` logs the pulls and pushes it serves. `--previous` shows the log of the container that crashed before the current one, which is the one with the cause. Add `-f` to follow a log while you repeat the action that fails.

Job output is different: the job service writes the log of each job to its volume, and Harbor shows it in the portal on the page of the job, such as a garbage collection or a scan.

## Common pitfalls

> [!WARNING]
> - **Reading only the current log of a crashing pod.** Use `--previous` to see why the last container stopped.
> - **Reading the wrong component.** A push error in the client usually comes from `registry` or `core`; check both.
> - **Scrolling through the whole log.** Use `--tail` and `--since` to look at the minutes around the failure.
> - **Ignoring pod events.** A missing volume or a failed probe appears in `describe`, not in the log.
