# Solution: Build A Repository Report With The Harbor CLI

Work the task yourself first. Running `astrona submit -c sections/section-030/capstone/labs/lab-01` after a step tells you which checks pass.

The grader checks three things: the current context, the report against Harbor's own data, and the Guest role of `inventory-reader`.

## Step 1: Save and use a read-only context

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws harbor login https://harbor.localtest.me:8443 --username inventory-reader \
  --password Inventory-read-123 --context-name inventory-reader
ws harbor context get credentials.username
```

The login makes the new context current, and `get` prints `inventory-reader`. The `admin` context stays in the file, but no command uses it while `inventory-reader` is current.

## Step 2: Look at the JSON

Find the field names before you write the filter:

```sh
ws sh -c 'harbor repo list inventory -o json | jq ".Payload[] | .name"'
ws sh -c 'harbor artifact list inventory/podinfo -o json | jq ".Payload[] | {digest, tags: [.tags[]?.name]}"'
```

The repositories are `inventory/podinfo` and `inventory/charts/podinfo`. Each artifact has one `digest` and a list of `tags`, each with a `name`. The `podinfo` repository has two artifacts, tagged `6.14.1` and `6.15.0`.

## Step 3: Build the report

Loop over the repositories, list the artifacts of each, and turn every tag into one object. `jq -s` collects the lines into one array:

```sh
ws sh -c '
  : > /tmp/rows.jsonl
  for repo in $(harbor repo list inventory -o json | jq -r ".Payload[].name"); do
    harbor artifact list "$repo" -o json \
      | jq -c --arg repo "$repo" ".Payload[] | .digest as \$digest | .tags[]? | {repository: \$repo, tag: .name, digest: \$digest}" \
      >> /tmp/rows.jsonl
  done
  jq -s "sort_by(.repository, .tag)" /tmp/rows.jsonl > /root/inventory-report.json'
ws cat /root/inventory-report.json
```

The report has three objects: `inventory/charts/podinfo` `6.15.0`, and `inventory/podinfo` `6.14.1` and `6.15.0`, each with its digest. An artifact without a tag produces no line, because `.tags[]?` yields nothing for it; the report only lists tags.

## Step 4: Check the report against the registry

A digest from the report must be the digest the registry serves for that tag:

```sh
ws regctl registry login harbor.localtest.me:8443 -u inventory-reader -p Inventory-read-123
ws regctl image digest harbor.localtest.me:8443/inventory/podinfo:6.15.0
```

The value is the same as in the report.

## Step 5: Submit

```sh
astrona submit -c sections/section-030/capstone/labs/lab-01
```

## Why the obvious shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| Building the report as `admin` | The report may be right, but it was not made with read-only rights; the grader checks the current context |
| Making `inventory-reader` a Developer to see more | A Guest already sees every repository of the project; the grader checks the role |
| Parsing the table output | Column layout changes between CLI versions, and long digests are cut |
| Taking only the first tag of each artifact | An artifact with two tags would appear once instead of twice |
