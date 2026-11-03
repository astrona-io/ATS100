# Previewing And Applying An Upgrade

A `helm upgrade` renders the chart again and applies the difference to the cluster. If the command starts from the wrong values, it applies the wrong configuration to a working Harbor. This part shows how to keep the current values, how to preview the change, and how to check the result.

## Where the values come from

Helm builds the values of an upgrade from the chart defaults plus what you give it. There are two safe ways to keep the values of the running release:

- `--reuse-values` starts from the values of the last revision and applies your `--set` options on top.
- `--values harbor-values.yaml` uses a file that holds all the values you want. The file saved before the upgrade is the starting point.

An upgrade with neither option falls back to the chart defaults: Harbor would be exposed through an ingress, with the external URL `https://core.harbor.domain` and a new certificate. In this course, `certSource: secret` keeps the certificate in the Secret `harbor-tls`, so the certificate does not change, but the other defaults still apply.

## Preview with a dry run

`--dry-run` renders the templates and prints the release without changing the cluster. Preview a change to the log level:

<!-- astrona:playground:renew -->

```sh
helm -n harbor upgrade harbor harbor/harbor --version 1.19.4 --reuse-values --set logLevel=debug --dry-run | head -n 40
```

The output starts with the release information and the computed values, then the rendered manifests. A dry run proves that the chart renders and shows which values Helm will use. It does not prove that the new pods will start.

## Apply and wait

Apply the same change. `--wait` makes Helm wait until the Deployments and StatefulSets are ready, and `--timeout` sets how long it waits before it marks the revision as failed:

```sh
helm -n harbor upgrade harbor harbor/harbor --version 1.19.4 --reuse-values --set logLevel=debug --wait --timeout 10m
helm -n harbor history harbor
```

The history now has one more revision. The newest one has the status `deployed` and the previous one `superseded`. Compare the values of the two revisions:

```sh
helm -n harbor get values harbor --revision 1 -o yaml > old.yaml
helm -n harbor get values harbor -o yaml > new.yaml
diff old.yaml new.yaml
```

The only difference is the new `logLevel` line. A diff like this is the quickest proof that an upgrade changed what you meant it to change.

## Check the result

A successful `helm upgrade` means the Kubernetes objects are ready. It does not mean Harbor works. Check with Harbor itself:

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
kubectl -n harbor get pods
ws curl -sS https://harbor.localtest.me:8443/api/v2.0/health | ws jq -r '.status'
ws curl -sS -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/systeminfo | ws jq '{harbor_version, external_url}'
```

Every pod should be running, the overall status should be `healthy`, and `external_url` should still be the address clients use. Finish with a push, the operation users depend on:

```sh
ws oras login harbor.localtest.me:8443 -u admin -p Harbor12345
ws sh -c 'echo ok > /tmp/check.txt && cd /tmp && oras push harbor.localtest.me:8443/library/upgrade-check:1 check.txt:text/plain'
```

The `library` project exists in every new Harbor. The push proves the full path through `nginx`, `core` and the `registry`.

You can now apply a change without losing values and prove it worked. The open question is what to do when the wait ends in an error.

## Common pitfalls

> [!WARNING]
> - **Upgrading without `--reuse-values` or a values file.** Helm falls back to the chart defaults.
> - **Reading a dry run as a guarantee.** It checks the templates, not the images, the node resources or the application.
> - **Leaving out `--wait`.** The command returns while pods are still starting, and a failure is not recorded.
> - **Trusting the pod list alone.** A Running pod can still be unhealthy; read the health API.
