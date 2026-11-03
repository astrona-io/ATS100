# When An Upgrade Fails

Sooner or later an upgrade ends in an error: an image tag does not exist, a node is out of memory, a setting is invalid. What matters then is to read what Helm and Kubernetes recorded and to return to the last working revision without losing data. This part makes an upgrade fail on purpose, reads the evidence, and rolls back.

## Cause a failure

Point the registry at an image tag that does not exist. `registry.registry.image.tag` is the chart value for the tag of the `registry` container. The timeout is short so that the failure comes soon:

<!-- astrona:playground:renew -->

```sh
helm -n harbor upgrade harbor harbor/harbor --version 1.19.4 --reuse-values --set registry.registry.image.tag=v0.0.0-missing --wait --timeout 3m
```

After three minutes Helm reports that it timed out waiting for the condition. The revision it created is recorded as `failed`.

## Read the evidence

First look at the Helm history, then at the pods:

```sh
helm -n harbor history harbor
kubectl -n harbor get pods
```

The history shows the newest revision with the status `failed` and the one before it as `superseded`. In the pod list, a new `harbor-registry` pod is in `ErrImagePull` or `ImagePullBackOff`. The Deployment uses a rolling update: it starts the new pod first and removes the old pod only when the new one is ready. The old pod keeps running, so Harbor still answers, but the cluster is not in the state the release claims.

Ask Kubernetes why the new pod cannot start:

```sh
kubectl -n harbor describe pod -l component=registry
```

The `Events` section at the end names the image and the pull error. Always read these events before you choose a fix; the same symptom has other causes, such as a missing pull secret or a full node disk.

## Roll back

`helm rollback` applies the values and manifests of an earlier revision. Give it the number of the last good revision from the history, here shown as `<GOOD>`:

```sh
helm -n harbor rollback harbor <GOOD> --wait --timeout 10m
helm -n harbor history harbor
kubectl -n harbor get pods
```

A rollback does not delete the failed revision. Helm adds a new revision whose description is `Rollback to <GOOD>`, and the history now shows the whole story: good, failed, rolled back. The broken pod is gone and the registry runs its original image.

Check the image to be sure:

```sh
kubectl -n harbor get deployment harbor-registry -o jsonpath='{.spec.template.spec.containers[?(@.name=="registry")].image}'
```

The tag is `v2.15.4` again, as in the original release.

Rolling back is the right first step when a change is bad and nothing else changed. If you want to try the change again with a fix, use a new `helm upgrade` afterwards; a rollback is not the place to experiment.

## Common pitfalls

> [!WARNING]
> - **Uninstalling the release.** `helm uninstall` removes the history, and with no persistence every artifact is lost.
> - **Deleting the failing pod.** The Deployment recreates it with the same wrong image.
> - **Editing the Deployment with `kubectl`.** The release and the cluster then disagree, and the next upgrade overwrites the edit.
> - **Rolling back to the failed revision.** Use the last revision whose status is `superseded` or `deployed`.

## Your mission: Roll Back A Failed Harbor Upgrade

You can now read the history of a release and return to a good revision. The graded lab gives you a release whose last upgrade failed, and asks you to roll it back without removing anything.

The lab runs in its own cluster, so first pause your playground. Nothing in it is lost:

```sh
astrona stop ats-100-playground-020-04
```

Then start the lab:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS100.git -c sections/section-020/module-04/labs/lab-01
```

The task is on the next page. Solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-020/module-04/labs/lab-01
```

When the lab is done, remove it and start your playground again:

```sh
astrona destroy ats-100-lab-020-04
astrona start ats-100-playground-020-04
```
