# Users, Members And Roles

A project is only useful when the right people can use it. In Harbor a **user** is an account, and a **member** is a user with a role in one project. This part creates a user, adds it to a project and reads the role it really received, because the CLI and the REST API count roles differently.

## Create a user

Users are created by an administrator:

<!-- astrona:playground:renew -->

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
wst() { kubectl -n workstation exec -it deploy/workstation -- "$@"; }
ws harbor login https://harbor.localtest.me:8443 --username admin \
  --password Harbor12345 --context-name admin --skip-verify-client
ws harbor user create --username billing-dev --email billing-dev@example.com \
  --realname "Billing Dev" --password 'Billing-dev-123' --comment "lab user"
wst harbor user list
```

The command takes the user name, email address, real name, password and an optional comment as flags. The password must meet Harbor's password rules, which require upper case, lower case and a digit. `harbor user elevate` makes a user a system administrator and `harbor user password` changes a password, so treat both as sensitive. `harbor user delete` removes an account.

## Add a member to a project

```sh
ws harbor project create billing --storage-limit=-1
ws harbor project member create billing --username billing-dev --roleid 1
wst harbor project member list billing
```

The member list shows `billing-dev` with a role name. The roles of a project are Project Admin, Maintainer, Developer, Guest and Limited Guest. A Developer can push and pull, a Guest can only pull and read, and only a Project Admin can add members.

## The role number

The REST API numbers the roles 1 for Project Admin, 2 for Developer, 3 for Guest, 4 for Maintainer and 5 for Limited Guest. The CLI v0.0.27 adds 1 to the number you give `--roleid`, so `--roleid 1` produces role 2, a Developer. Do not trust the number; read the result from the API:

```sh
ws sh -c 'curl -sS -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/projects/billing/members | jq ".[] | {entity_name, role_name, role_id}"'
```

The output shows `role_name` as `developer` and `role_id` as 2. If you had passed `--roleid 2`, the role would be `guest`, and the member would have the wrong access without any error.

## Change and remove a member

`harbor project member update` changes a role and `harbor project member delete` removes a member. Because of the offset, check the result with the API after every role change. The member commands also accept a member ID, which `harbor project member list -o json` shows.

## Common pitfalls

> [!WARNING]
> - **Trusting `--roleid`.** The CLI adds 1 to the number. Verify with `role_name` from the REST API.
> - **Making everyone a Project Admin.** A Developer is enough to push and pull; give the least role that works.
> - **Putting passwords in scripts.** The `--password` flag shows in the process list and the shell history. Read it from a secret in real use.
> - **Adding a member before the user exists.** Create the user first, or the command fails with a not-found error.
