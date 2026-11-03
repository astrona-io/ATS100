# Summary

The `harbor` CLI turns routine Harbor administration into short commands. Doing it safely comes down to choosing the narrowest command and checking the result.

## What you learned

`harbor project create <name> --storage-limit=-1` creates a private project with no quota; the flag is required without a terminal, and `--public` is opt-in. `harbor project list`, `view` and `delete` read and remove projects, and a project that still holds repositories cannot be deleted.

`harbor user create` makes an account, and `harbor project member create <project> --username <name> --roleid <n>` adds it to a project. The CLI v0.0.27 adds 1 to `--roleid`, so `--roleid 1` gives a Developer, which is role 2 in the REST API. The role actually granted is read from the API, not assumed.

A repository holds artifacts, and an artifact is a digest that can carry many tags. `harbor artifact tags delete <project>/<repository>/<reference> <tag>` removes one tag and keeps the image. `harbor artifact delete` removes the artifact and all its tags, and `harbor repo delete` removes everything in the repository. Deleting frees disk only after garbage collection, and `harbor quota list` shows project usage against its limit. Key facts to remember:

- Pass `--storage-limit` when creating a project.
- Check member roles with the REST API after every change.
- Use `tags delete` to remove a tag, never `artifact delete`.
- Disk space returns after garbage collection, not at delete time.

<!-- astrona:playground:destroy -->
