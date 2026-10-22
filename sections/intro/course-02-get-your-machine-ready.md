# Get Your Machine Ready

Every playground and lab in this course runs on your own machine, in a small Kubernetes cluster. A tool called `astrona` builds it for you, sets it up, grades your work and removes it again. This page gets your machine ready: first the tools you need, then the handful of `astrona` commands you will use every day, and last what to do when a start goes wrong.

## What you need

Every section needs the same set of tools. Install these before you start:

- **A container engine:** Docker or Podman. The cluster runs inside it.
- **`kind`:** runs Kubernetes inside the container engine.
- **`kubectl`:** talks to the cluster. Every Harbor command in this course runs through `kubectl exec` in the workstation pod, so you do not need Harbor's tools on your machine.
- **`helm`:** installs and changes Harbor. Each playground and lab also puts Helm 3.22.1 in `/usr/local/bin` or `~/.local/bin`, so the version always matches the course.
- **The astrona command-line tool.**
- **`jq`:** reads JSON, so you can pick out one field of Helm's or Harbor's output.
- **A web browser:** some pages open Harbor's web portal through `kubectl port-forward`.

Harbor runs many components, so it needs memory. Give your container engine at least **4 GiB**. The playgrounds and labs also need **outbound internet** while they start: they download Helm and the client tools from GitHub, Harbor's images from Docker Hub, Trivy's vulnerability database and the podinfo example from `ghcr.io`. The first start of an environment can take up to fifteen minutes. Without outbound internet, the start fails with download errors that have nothing to do with Harbor.

## Reaching Harbor

Harbor's address is `https://harbor.localtest.me:8443` everywhere. Inside the cluster, the environment points that name at Harbor. On your machine, the name `harbor.localtest.me` is a public DNS name for `127.0.0.1`, so a port-forward makes the web portal answer at the same address:

```sh
kubectl -n harbor port-forward svc/harbor 8443:8443
```

Your browser warns about the certificate, because only the workstation trusts the lab's certificate authority. Accept the warning for the lab only. Some home routers block DNS answers that point at `127.0.0.1`; if the browser cannot find `harbor.localtest.me`, add this line to `/etc/hosts` on your machine:

```
127.0.0.1 harbor.localtest.me
```

You do not have to check your tools by hand. Let `astrona` look at your machine for you:

```sh
astrona setup
```

`astrona setup` looks at what is missing, shows you each step it would take, and asks before it does anything. On macOS it can install `kind`, `kubectl` and Podman. Install `helm` and `jq` yourself.

Later, you can check your machine at any time:

```sh
astrona check
```

## The commands you use every day

Once your machine is ready, you need only a handful of `astrona` commands. Each module page and lab page shows the exact command to copy, so you do not need to remember paths. This section walks through them in the order you meet them: sign in, start, pause, submit and clean up.

Labs from the course catalog are tied to your Astrona account, so you sign in first:

```sh
astrona login
```

Next you start a playground or a lab. Each module page and lab page shows the exact `astrona run` command for it. It looks like this:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS100.git -c sections/section-010/module-01/playground
```

When the cluster is ready, `kubectl` already points at it.

A chapter that sends you to a lab asks you to pause the playground first. Pausing frees your machine's memory but keeps everything you built:

```sh
astrona stop <name>
```

When the lab is done, start the playground again and carry on where you left off:

```sh
astrona start <name>
```

Inside a lab, you send your work for grading with `astrona submit`. The grader checks the live cluster. It pushes and reads artifacts, calls Harbor's API and checks the Helm release, so your fix has to actually work, not only make an error message go away. Each lab page shows the exact command:

```sh
astrona submit -c sections/section-010/module-01/labs/lab-01
```

You can submit as often as you like.

When you are done with a playground or a lab, remove it:

```sh
astrona destroy <name>
```

The name is the environment's name, printed by `astrona run` and shown on each page (for example `ats-100-playground-010-01`). It is not the folder path. To see what is on your machine, list it:

```sh
astrona list
```

> [!WARNING]
> **Run one environment at a time.** Each playground and lab is a whole cluster with its own Harbor. Two running at once can use up your machine's memory, and it is easy to send a command to the wrong one. Pause or destroy the playground before you start the lab.

## When a start goes wrong

Sometimes a playground or lab does not start cleanly. Ask `astrona` what is wrong before you try anything else:

```sh
astrona doctor
```

It checks your machine, the lab's configuration and the running lab, and tells you how to fix what it finds.

If a start seems stuck, it is usually still pulling Harbor's images or waiting for Trivy to download its database. If it fails while it downloads something, check your network first, then the memory of your container engine. Remember also that a lab that starts with a Harbor that refuses pushes is often broken on purpose: the lab's task tells you when that is the case. With your machine ready and these commands at hand, you can start the first module.
