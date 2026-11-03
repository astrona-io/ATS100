# Manage Projects, Members And Artifacts With The Harbor CLI

A new team asks for a place to push images, one developer must be able to push, and last quarter's test tags must go. In the web portal this is a dozen clicks. With the `harbor` command-line tool (CLI) it is three commands that you can repeat, review and put in a script.

This module builds on signing in and contexts. It uses the `harbor` CLI version **v0.0.27**, which calls the Harbor REST API v2.0, and its flags can change between versions. `harbor <command> --help` shows the flags of the version you run.

The module has four parts. **Projects** creates, lists, reads and deletes projects. **Users, Members And Roles** creates a user, adds it to a project and reads the role it received. **Repositories, Artifacts And Tags** looks inside a project and removes a tag without removing the image; a graded lab follows it. **Safe Deletion And Quotas** shows what deleting really frees and how quotas limit a project.

## Learning objectives

After this module you can:

- Create a project with `harbor project create`, including the required `--storage-limit` flag, and list, read and delete projects.
- Create users and add them to a project with `harbor project member create`.
- Explain the `--roleid` offset of the CLI and check the real role with the REST API.
- List repositories, artifacts and tags, and add or delete tags with `harbor artifact tags`.
- Tell deleting a tag from deleting an artifact, and explain why neither frees disk space at once.
- Read the quota of a project with `harbor quota list`.

## Before you start

You should be signed in to a Harbor with the CLI and know what a context is. You should know what a project, a repository, a tag and a digest are.

Your playground is a single-node `kind` cluster with **Harbor 2.15.4** at `https://harbor.localtest.me:8443`. The project `inventory` holds `podinfo:6.14.1`, `podinfo:6.15.0` and the Helm chart `charts/podinfo:6.15.0`. There are three users, all with lab-only passwords:

| User | Password | Role in `inventory` |
| --- | --- | --- |
| `admin` | `Harbor12345` | System administrator |
| `inventory-dev` | `Inventory-dev-123` | Developer: can push and pull |
| `inventory-reader` | `Inventory-read-123` | Guest: can only pull and read |

The `harbor` CLI runs in the **workstation** pod, which trusts Harbor's certificate authority. The pages run it through two short helpers: `ws` for commands that print JSON or nothing, and `wst`, which adds a terminal so that tables are drawn:

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
wst() { kubectl -n workstation exec -it deploy/workstation -- "$@"; }
```

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
