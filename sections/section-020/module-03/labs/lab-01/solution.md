# Solution: Move Settings From harbor.yml To Helm Values

Work the task yourself first. Running `astrona submit -c sections/section-020/module-03/labs/lab-01` after a step tells you which checks pass.

## Step 1: Read the old file and the chart values

```sh
kubectl -n workstation exec -i deploy/workstation -- cat /tmp/harbor.yml
helm repo add harbor https://helm.goharbor.io
helm show values harbor/harbor --version 1.19.4 | grep -n -i -E 'logLevel|maxJobWorkers|ignoreUnfixed'
```

`hostname` and `external_url` are already covered by `externalURL` and the exposure settings. The three open settings map like this:

| `harbor.yml` | Chart value |
| --- | --- |
| `log.level: debug` | `logLevel: debug` |
| `jobservice.max_job_workers: 20` | `jobservice.maxJobWorkers: 20` |
| `trivy.ignore_unfixed: true` | `trivy.ignoreUnfixed: true` |

## Step 2: Apply them

```sh
helm -n harbor upgrade harbor harbor/harbor --version 1.19.4 --reuse-values \
  --set logLevel=debug --set jobservice.maxJobWorkers=20 --set trivy.ignoreUnfixed=true --wait --timeout 5m
```

## Step 3: Check

```sh
helm -n harbor get values harbor
```

The three values are present next to the old ones.

## Step 4: Submit

```sh
astrona submit -c sections/section-020/module-03/labs/lab-01
```

## Why the shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| `helm upgrade` without `--reuse-values` | Chart defaults replace the exposure and certificate values |
| Copying `harbor.yml` as a values file | The key names are different; Helm ignores unknown keys silently |
| Editing the ConfigMaps | The next upgrade overwrites them |
