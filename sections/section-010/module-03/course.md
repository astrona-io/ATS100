# Where Harbor Keeps State: Storage, Logs And Backups

A pod restarts and a user asks whether the images are gone. A disk fills up and nobody knows which component to look at. Harbor is several programs, and each one keeps different data in a different place. Knowing who keeps what answers three practical questions: what survives a restart, where to look when something breaks, and what to copy before a risky change.

The module has four parts. **What Each Component Keeps** lists the volumes and the data behind them. **What Survives A Restart** stops components on purpose; a graded lab follows it. **Reading Logs And Health** finds the cause of a failure from logs and the health API. **Backing Up Harbor** dumps the database and names everything else a backup needs.

## Learning objectives

After this module you can:

- Name the data kept by `database`, `registry`, `redis`, `jobservice` and `trivy`, and the volume each uses.
- List StatefulSets, Deployments and PersistentVolumeClaims of a Harbor release.
- Explain which component loses data when its pod restarts and which does not.
- Explain why Harbor cannot work when the database is stopped.
- Read component logs with `kubectl logs` and the health API.
- Dump the Harbor database with `pg_dump` and list what else a complete backup needs.

## Before you start

You should know the Harbor components and what a push does. You should know `kubectl get`, `kubectl logs` and what a PersistentVolumeClaim is.

Your playground is a single-node `kind` cluster with **Harbor 2.15.4** installed as the Helm release `harbor` in the namespace `harbor`. Harbor answers at `https://harbor.localtest.me:8443`; the administrator is `admin` with the lab-only password `Harbor12345`. Client tools run in the **workstation** pod:

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
```

The first start takes several minutes. Launch your playground now and keep it running while you read:

<!-- astrona:playground -->
