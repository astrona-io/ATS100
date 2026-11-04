# Solution: Remove Old Tags In Bulk With The Harbor CLI

Work the task yourself first. Running `astrona submit -c sections/section-030/module-03/labs/lab-01` after a step tells you which checks pass.

## Step 1: List the tags as data

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws sh -c 'harbor artifact list archive/podinfo -o json | jq -r ".Payload[].tags[]?.name"'
```

List output sits under `Payload`. The `?` in `tags[]?` skips untagged artifacts. The command prints one tag name per line.

## Step 2: Select and print first

```sh
ws sh -c 'harbor artifact list archive/podinfo -o json | jq -r ".Payload[].tags[]?.name | select(startswith(\"old-\"))"'
```

Check that the output holds only `old-1`, `old-2` and `old-3`.

## Step 3: Delete each tag

```sh
ws sh -c 'for t in $(harbor artifact list archive/podinfo -o json | jq -r ".Payload[].tags[]?.name | select(startswith(\"old-\"))"); do harbor artifact tags delete archive/podinfo/$t $t; done'
```

The tag name serves as the reference, and the last argument names the tag to delete. Three tags share the digest of `6.15.0`, so the artifact stays while its other tags exist.

## Step 4: Submit

```sh
astrona submit -c sections/section-030/module-03/labs/lab-01
```

## Why the shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| `harbor artifact delete archive/podinfo:old-1` | It removes the artifact and every tag, including `6.15.0` |
| `harbor repo delete archive/podinfo` | It removes all tags and artifacts |
| Parsing the table output | It needs a terminal and breaks when columns change |
