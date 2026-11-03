# Question

Solve this question on: `terminal`

**Time:** about 20 minutes · **Topic:** Harbor CLI

## Scenario

The shipping team needs its own project in Harbor. Its developer `shipping-dev` must be able to push to it. The `harbor` CLI in the workstation pod is already signed in as `admin` (lab-only password `Harbor12345`) in the context `admin`.

While you are in Harbor, clean up the repository `warehouse/podinfo`: it has the tags `6.15.0` and `old` on the same image, and the tag `old` must go. The tag `6.15.0` and the image must stay.

Run the CLI in the workstation pod:

```sh
kubectl -n workstation exec -i deploy/workstation -- harbor version
```

## Your task

1. Create the private project `shipping` with no storage quota.
2. Make the user `shipping-dev` a Developer in `shipping`.
3. Delete the tag `old` of `warehouse/podinfo`.

## Constraints

- Use the `harbor` CLI for these changes. Do not sign in again or change the CLI context.
- Do not delete the artifact, the repository or the project `warehouse`.
- Do not make `shipping-dev` a Project Admin.

## Done when

- The project `shipping` exists and is private.
- `shipping-dev` has the role Developer in `shipping`.
- `warehouse/podinfo` has only the tag `6.15.0`.
