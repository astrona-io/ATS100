# Solution: Fix A Wrong External URL In Harbor

Work the task yourself first. Running `astrona submit -c sections/section-020/module-02/labs/lab-01` after a step tells you which checks pass.

## Step 1: Read what Harbor advertises

```sh
kubectl -n workstation exec -i deploy/workstation -- curl -sSI https://harbor.localtest.me:8443/v2/
helm -n harbor get values harbor
```

The header `WWW-Authenticate` names a `realm` with a host that is not `harbor.localtest.me`. The Helm values show the same host in `externalURL`. Harbor builds the token address for clients from `externalURL`, so clients try to get a token there.

## Step 2: Correct the value on the same release

```sh
helm repo add harbor https://helm.goharbor.io
helm -n harbor upgrade harbor harbor/harbor --version 1.19.4 --reuse-values \
  --set externalURL=https://harbor.localtest.me:8443 --wait --timeout 5m
```

`--reuse-values` keeps the other values, including `certSource: secret` and the Secret `harbor-tls`.

## Step 3: Check

```sh
kubectl -n workstation exec -i deploy/workstation -- curl -sSI https://harbor.localtest.me:8443/v2/
helm -n harbor history harbor
```

The realm now names `harbor.localtest.me:8443`, and the history shows a new revision.

## Step 4: Submit

```sh
astrona submit -c sections/section-020/module-02/labs/lab-01
```

## Why the shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| `helm upgrade` without `--reuse-values` | The chart defaults replace the exposure and certificate values |
| `helm rollback` | It works only if the earlier revision had the right URL, and it hides the cause |
| Editing the `harbor-core` ConfigMap | Helm overwrites it at the next upgrade |
