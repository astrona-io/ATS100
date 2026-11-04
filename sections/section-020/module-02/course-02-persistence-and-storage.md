# Persistence And Storage Backends

By default the chart asks Kubernetes for a volume for every component that keeps data. This part shows the settings that control volumes, and the setting that moves image data out of the cluster into object storage.

## Turning persistence on or off

`persistence.enabled` decides whether the chart creates PersistentVolumeClaims. With `false`, the pods use temporary storage, and everything on it disappears when the pod is replaced: this is fine for a short lab and wrong for any installation that keeps images. Check the playground:

<!-- astrona:playground:renew -->

```sh
helm -n harbor get values harbor -o yaml | grep -A2 '^persistence'
kubectl -n harbor get pvc
```

The first command shows the `persistence` block of your release. The second lists the claims the chart created, if any.

## Claim settings

With persistence on, each component has its own block under `persistence.persistentVolumeClaim`: `registry`, `jobservice`, `database`, `redis` and `trivy`. In each, `storageClass` selects the class (empty uses the cluster default, and `"-"` disables dynamic provisioning), `size` sets the size, `accessMode` sets the mode, and `existingClaim` uses a claim you created yourself. A size can be raised later only when the storage class allows volume expansion.

## Image storage in object storage

Layers can live outside the cluster. `persistence.imageChartStorage.type` is `filesystem` (the default, on the registry claim) or one of `s3`, `gcs`, `azure`, `swift` or `oss`. For `s3` the block `imageChartStorage.s3` takes the bucket, region and credentials. With object storage the registry pod no longer needs a large volume, several registry replicas can share the data, and the backup of blobs moves to the storage service. The database and Redis still need volumes or external services.

## Common pitfalls

> [!WARNING]
> - **Installing with `persistence.enabled: false` outside a lab.** The first pod restart loses the data.
> - **Choosing a size that cannot grow.** Check that the storage class supports expansion.
> - **Switching `imageChartStorage` on a running installation.** Existing blobs stay in the old place; plan a copy.
> - **Putting storage keys into the values file in a repository.** Use an existing Secret for credentials.
