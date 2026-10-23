# Everyday Commands And Output Formats

Most work with a registry is looking things up: which projects exist, which repositories a project holds, which tags and digests a repository has, and whether the server is healthy. The `harbor` CLI answers each of these with one command, as a table for people or as JSON for scripts. This part runs the everyday commands and turns their output into data.

## Is the server there, and which one is it

Two commands describe the server itself. `harbor health` reads Harbor's health report, the status of every component. `harbor info` shows details of the current context and the server, such as the user and the Harbor version.

<!-- astrona:playground:renew -->

Run both as the developer user:

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
wst() { kubectl -n workstation exec -it deploy/workstation -- "$@"; }
ws harbor login https://harbor.localtest.me:8443 --username inventory-dev \
  --password Inventory-dev-123 --context-name inventory-dev
wst harbor health
wst harbor info
```

The `harbor` CLI (version 0.0.27) draws lists and views as a table only on a terminal, so these commands run through `wst`, which adds `-t` (a terminal) to `kubectl exec`.

`harbor health` lists components such as `core`, `database`, `jobservice`, `registry` and `trivy`, each with its status. Run these two first when a script fails: they tell you whether the problem is the server or the request.

## Projects, repositories and artifacts

The content commands follow Harbor's own structure, from the outside in. A project holds repositories, and a repository holds artifacts with their tags:

```sh
wst harbor project list
wst harbor repo list inventory
wst harbor artifact list inventory/podinfo
```

`harbor project list` shows `inventory` with its access level. `harbor repo list inventory` shows two repositories, `inventory/podinfo` and `inventory/charts/podinfo`, with their artifact counts. `harbor artifact list inventory/podinfo` shows two artifacts, tagged `6.14.1` and `6.15.0`, each with its digest, type, size and push time. Without an argument, `harbor artifact list` asks for the project and the repository interactively, which is useful at a terminal and useless in a script.

The commands only show what the current user may see. `inventory-dev` sees `inventory` because it is a member; a user who is not a member sees only public projects. Commands that change Harbor, such as `harbor project create` or `harbor user create`, also follow the user's role, so a Developer cannot create a user.

## Output for scripts

A table is easy to read and hard to parse. The global flag `-o` (`--output-format`) changes every command's output to `json`, `yaml` or `csv`. JSON is the best choice for scripts, because `jq` can pick out exactly the fields you need.

List the tags and digests of `inventory/podinfo` as JSON, and keep only those two fields:

```sh
ws sh -c 'harbor artifact list inventory/podinfo -o json | jq -r ".[] | \"\(.tags[0].name) \(.digest)\""'
```

Each line shows a tag and its digest, for example `6.15.0` followed by a `sha256:` value. The JSON follows Harbor's REST API model, so the field names are the same as in the API: `digest`, `tags`, `type`, `push_time`. A loop over `harbor repo list inventory -o json` and `harbor artifact list <repository> -o json` gives a full inventory of a project in a few lines of shell.

## When the CLI is not enough

The CLI covers the most common tasks, and it grows with each release. When it has no command for something, the REST API does: every CLI command is an API call, and `curl` with the same user can make it. Add `-v` (`--verbose`) to a `harbor` command to see more about what it does, which helps when a command fails without a clear message.

You can now check the server, walk from projects to artifacts, and turn any listing into JSON for a script. With signing in, contexts and these commands, you can do most daily Harbor work from a terminal.

## Common pitfalls

> [!WARNING]
> - **Parsing tables in scripts.** Columns change between CLI versions; use `-o json` and `jq`.
> - **Calling `harbor artifact list` without an argument in a script.** It waits for interactive input. Always pass `project/repository`.
> - **Expecting to see every project.** The CLI shows what the current user may see; check the context before you conclude a project is missing.
> - **Assuming one tag per artifact.** An artifact can have several tags or none; handle `tags` as a list.
