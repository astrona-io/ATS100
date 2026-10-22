# The harbor-helm Values That Matter

The `harbor-helm` chart has hundreds of values, but four of them decide whether clients can reach Harbor at all: how Harbor is exposed, the URL it believes clients use, whether it keeps data, and the first administrator password. This part reads those values on the running release, explains each one, and then breaks and repairs `externalURL`, the value that causes the most confusing failures.

## Read what the release was installed with

Helm keeps the values of every release. Ask it which values the release `harbor` was installed with; the output contains only the values that differ from the chart's defaults.

<!-- astrona:playground:renew -->

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
helm -n harbor list
helm -n harbor get values harbor
```

`helm list` shows the release `harbor`, the chart `harbor-1.19.4`, the app version `2.15.4` and a revision number. `helm get values` prints the values below. Harbor in this course was installed with exactly this file:

```yaml
expose:
  type: clusterIP
  tls:
    enabled: true
    certSource: auto
    auto:
      commonName: harbor.localtest.me
  clusterIP:
    name: harbor
    ports:
      httpPort: 8080
      httpsPort: 8443
externalURL: https://harbor.localtest.me:8443
harborAdminPassword: Harbor12345
persistence:
  enabled: false
trivy:
  enabled: true
metrics:
  enabled: false
```

The next sections take these values one at a time, starting with how Harbor is reached.

## expose: how clients reach Harbor

`expose.type` decides which Kubernetes object sits in front of `nginx` or the components:

| `expose.type` | What the chart creates | Typical use |
| --- | --- | --- |
| `ingress` (default) | An Ingress for `core` and the portal; no `nginx` | A cluster with an ingress controller |
| `clusterIP` | A ClusterIP Service named by `expose.clusterIP.name`, in front of `nginx` | Access from inside the cluster, or through a proxy |
| `nodePort` | A NodePort Service in front of `nginx` | Access on every node's IP address |
| `loadBalancer` | A LoadBalancer Service in front of `nginx` | A cloud load balancer |
| `route` | An OpenShift Route | OpenShift clusters |

This environment uses `clusterIP` with the name `harbor` and port `8443`, which is why the Service `harbor` answers on `8443`. `expose.tls` controls the certificate, which has its own story.

## externalURL: the address Harbor tells clients

`externalURL` is the URL, `protocol://host[:port]`, at which clients reach Harbor. `core` uses it for two things: the push and pull commands shown in the portal, and the **token realm**, the URL the `registry` puts in its `WWW-Authenticate` header when it refuses a request without a token. Every client follows that header to get its token, so `externalURL` must be an address every client can reach.

Two more values complete the picture. `persistence.enabled: false` makes every component use an `emptyDir` volume, so the data disappears with the pod; that suits a lab, never production. `harborAdminPassword` sets the password of `admin` only when Harbor first creates its database. Changing it later in the values changes nothing; the password then lives in the database and is changed in the portal or the API.

## Break externalURL and watch the token step fail

Seeing the failure once makes it easy to spot later. Change `externalURL` to an address the workstation cannot reach, and keep every other value:

```sh
helm -n harbor upgrade harbor harbor/harbor --version 1.19.4 --reuse-values \
  --set externalURL=https://harbor.example.com --wait --timeout 15m
```

Helm creates a new revision, and `core` restarts with the new setting. Read the registry's refusal again:

```sh
ws curl -sSI https://harbor.localtest.me:8443/v2/
```

The `WWW-Authenticate` header now names the realm `https://harbor.example.com/service/token`. A push from the workstation fails at the token step: the client tries to reach `harbor.example.com`, which does not point at this Harbor. Nothing is wrong with the registry, the certificate or the user; only the address is wrong.

Repair it with a values file, the way you would in a real installation, so the values are written down. Save the values shown above as `harbor-values.yaml`, then upgrade the release with it:

```sh
helm -n harbor upgrade harbor harbor/harbor --version 1.19.4 \
  --values harbor-values.yaml --wait --timeout 15m
```

Then check the result:

```sh
helm -n harbor get values harbor -o json | jq -r '.externalURL'
ws curl -sSI https://harbor.localtest.me:8443/v2/
ws regctl registry login harbor.localtest.me:8443 -u admin -p Harbor12345
ws regctl image copy ghcr.io/stefanprodan/podinfo:6.15.0 harbor.localtest.me:8443/inventory/podinfo:6.15.0
```

The value is back to `https://harbor.localtest.me:8443`, the realm names the right host, and the copy succeeds. `helm -n harbor history harbor` shows each upgrade as a new revision, so you can always see what changed and when.

You now know which values decide how Harbor is reached and why `externalURL` must match the address clients use. The certificate Harbor presents on that address is the remaining half of the installation.

> [!TIP]
> When a push fails with a host name you do not recognise, read the `WWW-Authenticate` header of `/v2/` first. It shows the token realm, which is `externalURL` plus `/service/token`.

## Common pitfalls

> [!WARNING]
> - **Setting `externalURL` to the Service name only.** Clients outside the cluster cannot resolve it. Use the address the clients really use, with the port if it is not the default.
> - **Changing `harborAdminPassword` to reset a password.** It only applies at the first start. Change the password in Harbor instead.
> - **Running `helm upgrade` without `--reuse-values` or a values file.** Helm falls back to the chart defaults, which means `ingress`, `https://core.harbor.domain` and new certificates.
> - **Turning TLS off to make a push work.** It hides the address problem and creates a new one.

## Your mission: Fix The External URL Of A Helm Install

You can now read the values of a Harbor release, recognise a wrong `externalURL` from the token realm, and correct it with `helm upgrade`. The graded lab gives you a Harbor whose pushes fail at the token step, and asks you to correct its external URL without turning TLS off.

The lab runs in its own cluster, so first pause your playground. Nothing in it is lost:

```sh
astrona stop ats-100-playground-020-01
```

Then start the lab:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS100.git -c sections/section-020/module-01/labs/lab-01
```

The task is on the next page. Solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-020/module-01/labs/lab-01
```

When the lab is done, remove it and start your playground again:

```sh
astrona destroy ats-100-lab-020-01
astrona start ats-100-playground-020-01
```
