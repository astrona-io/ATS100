# Harbor's Data Model And The REST API

The registry knows repositories, manifests and blobs. Harbor knows more: projects, artifacts, tags and the people allowed to use them. When a script has to list or find content, it talks to the Harbor REST API v2.0, and it must use the right names. This part maps Harbor's objects to the API and to the OCI model.

## The four levels

A **project** is Harbor's unit of access control and quota. A **repository** is a named collection of artifacts inside one project; its full name starts with the project name, as in `inventory/podinfo`. An **artifact** is one manifest with its content, identified by its digest. A **tag** is a name for an artifact, and one artifact can have several tags.

The Harbor `database` holds projects, repository records, artifact records and tags. The `registry` stores the manifests and blobs. `core` keeps both in step: when the registry reports a push, `core` creates or updates the records.

## Walk down the API

Each level has a path. List the projects, then the repositories of one project, then the artifacts of one repository:

<!-- astrona:playground:renew -->

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws curl -sS -u admin:Harbor12345 'https://harbor.localtest.me:8443/api/v2.0/projects?name=inventory' | ws jq '.[0] | {name, project_id, repo_count}'
ws curl -sS -u admin:Harbor12345 'https://harbor.localtest.me:8443/api/v2.0/projects/inventory/repositories' | ws jq -r '.[].name'
ws curl -sS -u admin:Harbor12345 'https://harbor.localtest.me:8443/api/v2.0/projects/inventory/repositories/podinfo/artifacts' | ws jq '.[] | {digest, type, tags: [.tags[]?.name]}'
```

The repository names in the second answer include the project name. In the third request the repository is written without it: the path already names the project.

## Names with a slash

Nested repository names, such as `charts/podinfo`, contain a slash. A slash in a path segment must be encoded, and Harbor decodes the segment twice, so the slash is written `%252F` (the percent sign is itself encoded as `%25`):

```sh
ws regctl image copy ghcr.io/stefanprodan/charts/podinfo:6.15.0 harbor.localtest.me:8443/inventory/charts/podinfo:6.15.0
ws curl -sS -u admin:Harbor12345 'https://harbor.localtest.me:8443/api/v2.0/projects/inventory/repositories/charts%252Fpodinfo/artifacts/6.15.0' | ws jq '{type, digest}'
```

A single encoding (`charts%2Fpodinfo`) returns a not-found answer. The artifact is addressed by a reference at the end of the path: a tag or a digest.

## Tags and digests in the API

Read the same artifact by tag and by digest and compare:

```sh
DIGEST=$(ws regctl image digest harbor.localtest.me:8443/inventory/podinfo:6.15.0)
ws curl -sS -u admin:Harbor12345 "https://harbor.localtest.me:8443/api/v2.0/projects/inventory/repositories/podinfo/artifacts/$DIGEST" | ws jq '{digest, tags: [.tags[]?.name]}'
```

Both references return the same artifact. Harbor can also list tags and create or delete them for an artifact at `/artifacts/<reference>/tags`, which changes the name without changing the content.

## Pagination

List endpoints return a page of results, 10 items by default. A request can set `page_size` (up to 100) and `page`, and the response header `X-Total-Count` says how many items exist. A script that ignores this sees only the first page:

```sh
ws curl -sS -D - -o /dev/null -u admin:Harbor12345 'https://harbor.localtest.me:8443/api/v2.0/projects/inventory/repositories?page_size=1'
```

The headers include `X-Total-Count`, the number of repositories in the project, while the body holds one item.

You can now go from a pushed image to its record in Harbor and back to the digest in the registry. This closes the module's model: blobs and manifests in the registry, projects, repositories, artifacts and tags in Harbor.

## Common pitfalls

> [!WARNING]
> - **Single-encoding a nested name.** Use `%252F` for the slash in `charts/podinfo`.
> - **Putting the project name twice.** In `/projects/inventory/repositories/podinfo` the repository segment has no project prefix.
> - **Reading only the first page.** Set `page_size` or follow `page` until `X-Total-Count` is reached.
> - **Using the tag as an identity.** The digest identifies the artifact; a tag can be removed or moved.
