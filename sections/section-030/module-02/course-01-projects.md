# Projects

A project is the unit that Harbor uses for access, quota and policy. Every repository lives in exactly one project, so creating the right project is the first step of giving a team a place to push. This part signs in as the administrator and creates, reads and deletes projects with the CLI.

## Sign in as the administrator

Creating a project needs a user who may create projects. The administrator can:

<!-- astrona:playground:renew -->

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
wst() { kubectl -n workstation exec -it deploy/workstation -- "$@"; }
ws harbor login https://harbor.localtest.me:8443 --username admin \
  --password Harbor12345 --context-name admin --skip-verify-client
```

The context name `admin` makes the credential easy to find later with `harbor context list`.

## Create a project

```sh
ws harbor project create shipping --storage-limit=-1
```

The flag `--storage-limit` is required: without a terminal the CLI cannot ask for it, and it stops with an error. The value is a size in GiB, and `-1` means no limit. The project is private unless you add `--public`, which lets anyone pull from it without signing in. Two more flags exist for special projects: `--proxy-cache` together with `--registry-id` makes the project a pull-through cache of another registry.

## List and read projects

```sh
wst harbor project list
wst harbor project view shipping
```

`harbor project list` shows the projects the current user can see, with their access level. It filters with `--name`, `--private` and `--public`, and pages with `--page` and `--page-size`. `harbor project view` takes a name or a numeric project ID and shows the details of one project, including its quota. For scripts, ask for JSON; list output sits under `Payload`:

```sh
ws sh -c 'harbor project list -o json | jq -r ".Payload[] | \"\(.name) \(.metadata.public)\""'
```

Each line shows a project name and `true` or `false` for public access.

## Delete a project

```sh
ws harbor project delete shipping
```

Harbor refuses to delete a project that still holds repositories, so empty it first. The flag `--force` skips the confirmation question. A project cannot be restored after deletion, and its name can be used again.

## Common pitfalls

> [!WARNING]
> - **Leaving out `--storage-limit`.** The command fails without a terminal. Pass `--storage-limit=-1` for no quota.
> - **Creating a public project by mistake.** `--public` lets anyone pull without signing in. Leave it off unless that is the intent.
> - **Parsing the table.** Use `-o json` and `jq` in scripts, and read the items under `Payload`.
> - **Running as the wrong user.** A project created as `inventory-dev` has a different owner than one created as `admin`. Check the context before you create.
