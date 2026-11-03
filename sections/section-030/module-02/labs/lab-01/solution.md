# Solution: Create A Project And Clean Up Tags With The Harbor CLI

Work the task yourself first. Running `astrona submit -c sections/section-030/module-02/labs/lab-01` after a step tells you which checks pass.

The grader reads Harbor's REST API and checks the project, the role of `shipping-dev` and the tags of `warehouse/podinfo`.

## Step 1: Create the project

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws harbor project create shipping --storage-limit=-1
```

`--storage-limit` is required without a terminal, and `-1` means no quota. Projects are private unless you pass `--public`.

## Step 2: Add the member

The `harbor` CLI v0.0.27 adds 1 to the number given to `--roleid`, so `--roleid 1` makes a Developer:

```sh
ws harbor project member create shipping --username shipping-dev --roleid 1
ws curl -sS -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/projects/shipping/members | ws jq '.[] | {entity_name, role_name}'
```

The second command proves the role: `role_name` is `developer`. If it shows another role, remove the member in the portal or with the REST API and add it again with the right number.

## Step 3: Delete the tag

```sh
ws harbor artifact tags delete warehouse/podinfo/6.15.0 old
ws harbor artifact tags list warehouse/podinfo/6.15.0
```

The reference `warehouse/podinfo/6.15.0` names the artifact; the last argument is the tag to delete. The list shows only `6.15.0`. Run the last command through `wst` (a terminal) if it prints a table error.

## Step 4: Submit

```sh
astrona submit -c sections/section-030/module-02/labs/lab-01
```

## Why the shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| `harbor artifact delete` on the image | It removes the tag `6.15.0` and the image together |
| `harbor repo delete warehouse/podinfo` | It removes every tag and artifact in the repository |
| Trusting `--roleid 2` | The CLI adds 1, so the member becomes a Maintainer and the role check fails |
