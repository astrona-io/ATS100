# Exposure, Persistence And Secrets In The Harbor Chart

Three chart settings decide whether a Harbor installation is usable and safe: how clients reach it, where its data lives, and which secrets protect it. A wrong choice does not stop the installation. It lets the pods start and fails later, when a client logs in, a pod restarts or a password leaks.

The module has four parts. **Exposure And The External URL** compares the four ways to reach Harbor and shows what `externalURL` controls; a graded lab follows it. **Persistence And Storage Backends** covers volumes and object storage. **Secrets And Credentials** lists the secrets of the chart and how to supply your own. **Changing Settings Safely** applies changes with Helm and says which ones need which care.

## Learning objectives

After this module you can:

- Choose between `ingress`, `clusterIP`, `nodePort` and `loadBalancer` for `expose.type`.
- Explain what `externalURL` controls and what breaks when it is wrong.
- Describe `persistence.enabled`, the claim settings and `imageChartStorage`.
- Name the secrets of the chart: `secretKey`, the administrator password, the internal secrets and the TLS Secret.
- Supply secrets from existing Kubernetes Secrets instead of the values file.
- Change one setting on a running release with `helm upgrade --reuse-values`.

## Before you start

You should have installed Harbor with the chart once and know `helm get values`. You need to know what a Kubernetes Service, an Ingress and a Secret are.

Your playground is a single-node `kind` cluster with **Harbor 2.15.4** installed as the Helm release `harbor` in the namespace `harbor` (chart 1.19.4). Harbor answers at `https://harbor.localtest.me:8443`; the administrator is `admin` with the lab-only password `Harbor12345`. Client tools run in the **workstation** pod:

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
```

The first start takes several minutes. Launch your playground now and keep it running while you read:

<!-- astrona:playground -->
