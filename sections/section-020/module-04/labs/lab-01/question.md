# Question

Solve this question on: `terminal`

**Time:** about 20 minutes · **Topic:** Harbor upgrades

## Scenario

A colleague ran a `helm upgrade` on the Harbor release in the namespace `harbor` to try a different registry image. The upgrade reported an error and the colleague went home. Harbor still seems to answer, but the release is not in a clean state and one pod is not running.

Run Harbor tools in the workstation pod; run `helm` and `kubectl` on your machine (`admin` / `Harbor12345` are lab-only credentials):

```sh
helm -n harbor history harbor
kubectl -n harbor get pods
```

## Your task

1. Find the revision that failed and the last good revision in the Helm history.
2. Bring the release back to the last good revision with Helm, so that the registry uses its original image again.
3. Prove that every pod runs, Harbor is healthy and a push works.

## Constraints

- Do not uninstall or reinstall the release. The failed revision must stay in the history.
- Do not edit the Deployment or delete pods by hand to hide the problem.
- Do not turn TLS off and do not use any `--insecure` option.

## Done when

- The newest revision in `helm history` is deployed and its description says it is a rollback to the last good revision.
- The `registry` container of `harbor-registry` uses its original image and every pod in `harbor` is running.
- `/api/v2.0/health` reports every component healthy and a push to the project `inventory` succeeds.
