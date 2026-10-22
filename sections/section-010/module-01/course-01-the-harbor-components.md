# The Harbor Components And What They Do

When a request to Harbor fails, the error rarely names the component that broke. The registry might be stopped, the database might be unreachable, or the background job runner might be gone. To find the cause, you first need to know which components exist and what each one does. This part names every component, explains its job, and finds it in the cluster.

## One product, many components

Harbor is built from separate programs that talk to each other over the network. Each one runs in its own container, so it can fail, restart and scale on its own. The table lists them in the order a request usually meets them.

| Component | What it does |
| --- | --- |
| `nginx` | The entry point. It ends the TLS connection and sends each request on: web pages to `portal`, API calls to `core`, image traffic to `registry` |
| `portal` | The web user interface you open in a browser |
| `core` | Harbor's API server. It checks who you are, holds projects, users and policies, and runs the **token service** that the registry trusts |
| `registry` | The CNCF Distribution registry. It stores the layers and manifests of every artifact and answers the OCI distribution API under `/v2/` |
| `jobservice` | Runs background jobs: replication, scanning, garbage collection, tag retention and webhooks |
| `trivy` | The Trivy adapter. It scans artifacts for known vulnerabilities and builds software bills of materials (SBOMs) |
| `database` | PostgreSQL. It holds Harbor's own data: projects, users, policies, scan results |
| `redis` | Redis. It holds the job queue for `jobservice` and caches for `core` |

Two words in the table need a definition. TLS (Transport Layer Security) is the protocol that encrypts HTTPS connections, and a certificate proves the server's name to the client. A token service hands out short-lived tokens that say what a client may do; the registry only accepts requests that carry a valid token.

The split between `core` and `registry` matters most. The `registry` component knows nothing about projects or users. It stores blobs and manifests, and it accepts a request only if the token proves the client may do it. The `core` component makes that decision and signs the token. So a wrong password fails in `core`, and a full disk fails in `registry`.

## Find the components in the cluster

The `harbor-helm` chart creates one Kubernetes workload per component, all with the prefix of the Helm release name, `harbor`. Stateless components run as Deployments. The components that keep data run as StatefulSets, so each pod keeps a stable name.

<!-- astrona:playground:renew -->

List them:

```sh
kubectl -n harbor get deployments,statefulsets
```

You should see five Deployments, `harbor-core`, `harbor-jobservice`, `harbor-nginx`, `harbor-portal` and `harbor-registry`, and three StatefulSets, `harbor-database`, `harbor-redis` and `harbor-trivy`. Each one should show all its replicas ready. In this lab environment every component has one replica.

Each pod carries the label `component` with the component's name, which is handy when you want the pods of one component only. Look at the registry:

```sh
kubectl -n harbor get pods -l component=registry
kubectl -n harbor describe deployment harbor-registry
```

The `describe` output shows that the registry pod runs two containers, `registry` and `registryctl`. The second one is a small control service that `core` calls, for example to start garbage collection. You will see `registryctl` again in the health report.

The Services tell you how the components reach each other. List them:

```sh
kubectl -n harbor get services
```

Every component has a Service of its own, such as `harbor-core` or `harbor-registry`. One Service is different: `harbor`, without a suffix. It points at `nginx`, and it is the only one a client should use. In this environment it listens on port `8443` for HTTPS.

## How Harbor is reached in this course

Harbor's address is `https://harbor.localtest.me:8443`, both inside the cluster and on your machine. The name `harbor.localtest.me` is a public DNS name that points at `127.0.0.1`. Inside the cluster, the environment changed the cluster DNS server (CoreDNS) so the same name points at the Service `harbor`. On your machine, a port-forward makes the web portal answer at the same address.

Check that the workstation reaches Harbor by name:

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws curl -sS https://harbor.localtest.me:8443/api/v2.0/ping
```

The answer is the word `Pong`. The request went from the workstation to the Service `harbor`, then to `nginx`, then to `core`, which answers `/api/v2.0/ping`. The workstation trusts the certificate, because it downloaded Harbor's CA when it started.

To see the web portal, start a port-forward in a second terminal and leave it running:

```sh
kubectl -n harbor port-forward svc/harbor 8443:8443
```

Then open `https://harbor.localtest.me:8443` in your browser. The browser warns about the certificate, because your machine does not trust the lab CA; accept the warning for this lab only. Sign in as `admin` with the password `Harbor12345`. The page you see is served by `portal`, and every number on it comes from `core`.

You now know the eight components, where each one runs and which Service a client uses. A push uses several of them in a fixed order, and when one is missing, the push fails in a way that points at it. That order is the next question.

## Common pitfalls

> [!WARNING]
> - **Calling a component's own Service.** Clients use the Service `harbor` (`nginx`). Calling `harbor-registry` or `harbor-core` directly skips TLS and authentication and behaves differently.
> - **Mixing up `core` and `registry`.** `core` decides who may do what and signs tokens; `registry` only stores and serves content. An authentication error is a `core` question.
> - **Forgetting `jobservice`.** Nothing in the web portal breaks when it stops, but scans, replication and retention never run.
> - **Expecting the browser to trust the lab certificate.** Only the workstation trusts the lab CA. Never change the course's commands to skip verification.
