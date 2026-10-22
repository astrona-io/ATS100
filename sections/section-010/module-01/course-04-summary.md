# Summary

A running Harbor is several components that each do one job, and most problems become simple once you know which component a request reached and where it stopped.

## What you learned

Harbor runs `nginx` as the entry point, `portal` for the web interface, `core` for the API, authentication, projects and the token service, `registry` for the stored content, `jobservice` for background jobs, `trivy` for scanning, and PostgreSQL (`database`) and Redis (`redis`) for data and the job queue. The `harbor-helm` chart creates one Deployment or StatefulSet per component, with a matching Service, and clients use only the Service `harbor` in front of `nginx`.

A push is a short conversation. The `registry` refuses the first request and names the token service in its `WWW-Authenticate` header. `core` checks the user and the project and signs a token, and the `registry` accepts the request that carries it. The token realm comes from Harbor's external URL, so a wrong external URL breaks every push at the token step.

`/api/v2.0/health` lists every component with its status, and `/api/v2.0/systeminfo` shows the version, the external URL and the authentication mode. The portal can work while `registry` or `jobservice` is down, so the health report is the first thing to read. A stopped component is brought back on its own workload; reinstalling Harbor is never the first step.

Harbor stores every kind of content as an OCI artifact: a manifest plus blobs. Images, Helm charts, signatures, SBOMs and plain files pushed with `oras` all live side by side, and `core` shows each one with its type. Key facts to remember:

- Every repository lives in a project, and projects are not created by a push.
- A tag can move; a digest names exactly one artifact.
- Two copies are the same artifact when their digests match.
- Nested repository names are encoded twice in API paths.

<!-- astrona:playground:destroy -->
