# Loops, jq And Safe Bulk Changes

The value of a script is that one command can change many objects. The danger is the same: one wrong filter changes the wrong objects, all at once. This part builds a bulk change in three steps, list, print, run, so that you see the change before it happens.

## Step 1: List the candidates

<!-- astrona:playground:renew -->

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws harbor login https://harbor.localtest.me:8443 --username admin \
  --password Harbor12345 --context-name admin --skip-verify-client
ws sh -c 'harbor artifact list inventory/podinfo -o json | jq -r ".Payload[] | .tags[]?.name"'
```

The output is every tag of the repository, one per line. `.Payload[]` walks the artifacts, `.tags[]?` walks the tags of each and skips artifacts without tags. An artifact can have several tags or none, so always handle `tags` as a list.

## Step 2: Select and print

Add the filter, and print the command that you would run instead of running it:

```sh
ws sh -c 'for t in $(harbor artifact list inventory/podinfo -o json | jq -r ".Payload[].tags[]?.name | select(startswith(\"6.14\"))"); do echo harbor artifact tags delete inventory/podinfo/$t $t; done'
```

The output has one line for every tag that starts with `6.14`. `echo` shows the command without running it. Read the list. If anything unwanted is in it, fix the filter now.

## Step 3: Run it

Remove `echo` to run the commands. For tags, use `harbor artifact tags delete`, which removes a tag and keeps the artifact, never `harbor artifact delete`, which removes the artifact with all of its tags.

## Make a bulk change repeatable

Keep the filter in a variable or a function, print before you run, and log what was changed. If a list may be long, ask for pages with `--page` and `--page-size`, or the loop only sees the first page.

## Common pitfalls

> [!WARNING]
> - **Running before printing.** Print the commands first and read them.
> - **Missing the `?` in `tags[]?`.** A `jq` error on untagged artifacts stops the loop half way.
> - **Forgetting paging.** Large repositories return one page at a time.
> - **Using `artifact delete` for tags.** The artifact and all its tags are gone.

## Your mission: Remove Old Tags In Bulk With The Harbor CLI

You can now list, filter, print and run a bulk change. The graded lab gives you a repository with test tags named `old-1`, `old-2` and `old-3` next to the release tags, and asks you to remove the test tags only.

The lab runs in its own cluster, so first pause your playground. Nothing in it is lost:

```sh
astrona stop ats-100-playground-030-03
```

Then start the lab:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS100.git -c sections/section-030/module-03/labs/lab-01
```

The task is on the next page. Solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-030/module-03/labs/lab-01
```

When the lab is done, remove it and start your playground again:

```sh
astrona destroy ats-100-lab-030-03
astrona start ats-100-playground-030-03
```
