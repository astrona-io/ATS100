# Summary

Harbor keeps its state in a few well-defined places, and almost every operational question reduces to which one.

## What you learned

The `database` keeps records (users, projects, artifacts, tags, policies, scan results), the `registry` keeps blobs and manifests, `redis` keeps queues and caches, `jobservice` keeps job logs and `trivy` keeps its vulnerability data. `core` and `portal` keep nothing. The StatefulSets `harbor-database`, `harbor-redis` and `harbor-trivy` and the claims behind them survive a pod restart, so a replaced pod finds its data again.

Without the database, `core` cannot work, and sign-in and pushes stop. The cure is to start the database again, not to delete its claim. The health API names the failing component, `kubectl describe` shows events, and `kubectl logs` (with `--previous` for a crash) shows the cause. A complete backup is a database dump, the registry storage, the values file and the Secrets including `secretKey`. Key facts to remember:

- Records are in the database, bytes are in the registry storage.
- Scale a StatefulSet to zero to stop it; never delete its claim.
- Health API first, then pods, then logs.
- A backup that lacks `secretKey` or the storage is incomplete.

<!-- astrona:playground:destroy -->
