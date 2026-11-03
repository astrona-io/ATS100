# Solution: Roll Back A Failed Harbor Upgrade

Work the task yourself first. Running `astrona submit -c sections/section-020/module-04/labs/lab-01` after a step tells you which checks pass.

The grader checks that the newest revision is a deployed rollback to the last good revision, that the failed revision is still in the history, that the registry has its original image and every pod runs, and that Harbor is healthy and accepts a push.

## Step 1: Read the history

```sh
helm -n harbor history harbor
```

The table lists every revision with its status and description. The newest revision has the status `failed`. The revision before it has the status `superseded`: it is the last good one, and its number is what you roll back to.

## Step 2: See the symptom

```sh
kubectl -n harbor get pods
kubectl -n harbor describe pod -l component=registry | grep -i -A3 "image"
```

One `harbor-registry` pod is in `ErrImagePull` or `ImagePullBackOff`. It was created by the new ReplicaSet and asks for an image tag that does not exist. The old pod keeps running, which is why Harbor still answers.

## Step 3: Roll back

Use the number of the last good revision. Replace `<GOOD>` with it:

```sh
helm -n harbor rollback harbor <GOOD> --wait --timeout 10m
helm -n harbor history harbor
```

Helm creates a new revision that applies the old values and manifests. The description of that revision reads `Rollback to <GOOD>`. The failed revision stays in the history.

## Step 4: Prove the result

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
kubectl -n harbor get pods
ws curl -sS https://harbor.localtest.me:8443/api/v2.0/health | ws jq -r '.status'
ws regctl registry login harbor.localtest.me:8443 -u admin -p Harbor12345
ws regctl image copy ghcr.io/stefanprodan/podinfo:6.15.0 harbor.localtest.me:8443/inventory/podinfo:6.15.0
```

Every pod is running, the overall status is `healthy` and the copy finishes without an error.

## Step 5: Submit

```sh
astrona submit -c sections/section-020/module-04/labs/lab-01
```

## Why the shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| `helm uninstall` and a new install | The failed revision leaves the history and, with no persistence, every artifact is lost |
| Deleting the failing pod | The Deployment creates it again with the same wrong image |
| `kubectl edit deployment` | The cluster no longer matches the release, and the next `helm upgrade` overwrites the edit |
