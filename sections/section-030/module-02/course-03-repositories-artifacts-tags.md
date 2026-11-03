# Repositories, Artifacts And Tags

Inside a project, Harbor stores repositories; a repository stores artifacts; an artifact is identified by its digest and can carry any number of tags. Cleaning up means removing the right one of these three, and the commands are close enough to each other to make a costly mistake. This part walks through the structure and removes a tag without touching the image.

## Walk the structure

<!-- astrona:playground:renew -->

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
wst() { kubectl -n workstation exec -it deploy/workstation -- "$@"; }
ws harbor login https://harbor.localtest.me:8443 --username admin \
  --password Harbor12345 --context-name admin --skip-verify-client
wst harbor repo list inventory
wst harbor repo view inventory/podinfo
wst harbor artifact list inventory/podinfo
wst harbor artifact view inventory/podinfo:6.15.0
```

`harbor repo list` takes a project. `harbor repo view` takes `project/repository`. `harbor artifact list` takes `project/repository` and `harbor artifact view` takes that plus `:tag` or `@digest`. A repository name can contain slashes, as in `inventory/charts/podinfo`, where the project is `inventory` and the repository is `charts/podinfo`.

## Tags

A tag is a name that points at a digest. Several tags can point at the same artifact, and a tag can be moved to another artifact. The `tags` commands take the artifact reference as `project/repository/reference`, where the reference is a tag or a digest:

```sh
wst harbor artifact tags list inventory/podinfo/6.15.0
ws harbor artifact tags create inventory/podinfo/6.15.0 stable
wst harbor artifact tags list inventory/podinfo/6.15.0
```

The second list shows both `6.15.0` and `stable`. Both names point at the same digest, so the image exists once. Now remove the new tag:

```sh
ws harbor artifact tags delete inventory/podinfo/6.15.0 stable
wst harbor artifact tags list inventory/podinfo/6.15.0
```

The list shows `6.15.0` again. The artifact was not touched, and a pull by digest or by the tag `6.15.0` still works.

## Deleting an artifact

`harbor artifact delete` removes the artifact itself, and with it every tag that points at it. When you only want a tag gone, use `tags delete`. `harbor repo delete` removes a whole repository with all of its artifacts. Check what a name points at with `harbor artifact view` before you run either delete command.

## Common pitfalls

> [!WARNING]
> - **Using `artifact delete` to remove a tag.** It removes the artifact and every tag that points at it. Use `artifact tags delete`.
> - **Deleting the last tag of an artifact.** The artifact stays as an untagged artifact; it can be pulled by digest and is removed only by a delete or a retention rule.
> - **Mixing up the reference formats.** `artifact view` uses `project/repository:tag`; the `tags` commands use `project/repository/reference` with slashes.
> - **Forgetting immutability.** A project can lock tags. Deleting or moving such a tag is refused until the rule is changed.

## Your mission: Create A Project And Clean Up Tags With The Harbor CLI

You can now create a project, add a member with the right role and remove a tag without removing the image. The graded lab asks you to do all three in one session, as a team asked for it.

The lab runs in its own cluster, so first pause your playground. Nothing in it is lost:

```sh
astrona stop ats-100-playground-030-02
```

Then start the lab:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS100.git -c sections/section-030/module-02/labs/lab-01
```

The task is on the next page. Solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-030/module-02/labs/lab-01
```

When the lab is done, remove it and start your playground again:

```sh
astrona destroy ats-100-lab-030-02
astrona start ats-100-playground-030-02
```
