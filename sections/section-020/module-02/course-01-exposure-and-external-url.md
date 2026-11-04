# Exposure And The External URL

Harbor needs two answers about its address. How does traffic from outside the cluster reach the pods? And which address does Harbor tell its clients to use? The first is `expose`, the second is `externalURL`. They are separate settings, and mixing them up is the most common cause of a Harbor that answers in a browser but fails in `docker login`.

## The four ways to expose Harbor

`expose.type` selects how the Harbor Service is reached:

| Type | How clients reach Harbor | Typical use |
| --- | --- | --- |
| `ingress` | An Ingress controller routes the host name to Harbor (the chart default) | Clusters with an ingress controller |
| `clusterIP` | A Service address inside the cluster only | Labs, or when another component does the routing |
| `nodePort` | A fixed port on every node | Simple clusters without load balancers |
| `loadBalancer` | A cloud or on-premises load balancer with its own address | Clusters with a load balancer |

This playground uses `clusterIP`: a CoreDNS rewrite and a port-forward make `harbor.localtest.me:8443` reach the Service named `harbor`. Read the current settings:

<!-- astrona:playground:renew -->

```sh
helm -n harbor get values harbor -o yaml
kubectl -n harbor get svc harbor
```

The values show `expose.type: clusterIP` and the ports, and the Service has the same ports.

## What externalURL controls

`externalURL` is the address that clients use to reach Harbor. Harbor puts it into the commands it shows in the portal, into redirects, and, most importantly, into the token address in the `WWW-Authenticate` header of `/v2/`. A Docker or OCI client calls `/v2/`, reads that header, and then asks for a token at the address in it:

```sh
ws curl -sSI https://harbor.localtest.me:8443/v2/
```

The answer is `401 Unauthorized` with a header like `www-authenticate: Bearer realm="https://harbor.localtest.me:8443/service/token",service="harbor-registry"`. The `realm` is built from `externalURL`. If `externalURL` names a host the client cannot reach, the portal can still work, because the browser already has a working address, while every `docker login` fails when it follows the realm.

## Match the pieces

The host name in `externalURL`, the name in the certificate, and the name clients type must be the same. With `ingress` the host is also set in `expose.ingress.hosts.core`. With `loadBalancer` or `nodePort`, `externalURL` must carry the address and port that clients really use, not the port inside the cluster.

## Common pitfalls

> [!WARNING]
> - **Leaving the default `externalURL`.** The chart default is `https://core.harbor.domain`, which no client can reach.
> - **Setting the host in the Ingress but not in `externalURL`.** The portal opens and `docker login` follows the wrong realm.
> - **Forgetting the port.** A non-standard port belongs in `externalURL`.
> - **Changing the URL without changing the certificate.** The name in the certificate must match the new host.

## Your mission: Fix A Wrong External URL In Harbor

You can now read the address Harbor advertises and tell which value it comes from. The graded lab gives you a Harbor whose `externalURL` was changed to a wrong host, and asks you to correct it without losing any other setting.

The lab runs in its own cluster, so first pause your playground. Nothing in it is lost:

```sh
astrona stop ats-100-playground-020-02
```

Then start the lab:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS100.git -c sections/section-020/module-02/labs/lab-01
```

The task is on the next page. Solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-020/module-02/labs/lab-01
```

When the lab is done, remove it and start your playground again:

```sh
astrona destroy ats-100-lab-020-02
astrona start ats-100-playground-020-02
```
