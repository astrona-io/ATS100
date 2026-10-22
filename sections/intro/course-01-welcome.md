# Welcome To The Course

This course trains you for the **Architecture, Installation & Harbor CLI Basics** part of the Astrona **Harbor** training path. That part is 10% of the path. This page tells you who the course is for, what you can do at the end, which words and example setup it uses, and how its pages fit together.

## Who this course is for

You know your way around Kubernetes: namespaces, Deployments, StatefulSets, Services, Secrets, `kubectl get`, `kubectl logs` and `kubectl exec`. You know what a container image is and what pushing and pulling one means. You have heard of Helm. You do not need to know Harbor yet. Each new idea is explained the first time it appears.

## What you can do at the end

Harbor is a registry you install, run and talk to, so this course does not ask you to remember words. It asks you to install Harbor, find the part that broke, and prove it works again with a real push. The course has three topics, and each one turns into a set of skills you will practise.

The first topic is **Harbor's architecture and the artifacts it stores**. You will learn to:

- Name Harbor's components and say what each one does.
- Follow a push through the proxy, the token service and the registry.
- Read Harbor's health report and bring a stopped component back.
- Store images, Helm charts and plain files as OCI artifacts, and compare them by digest.

Harbor only works for its clients if it is installed with the right address and certificate, so the second topic is **installing Harbor**. You will learn to:

- Read and change a Harbor installation with the `harbor-helm` chart.
- Set the external URL clients use, and recognise when it is wrong.
- Choose where Harbor's TLS certificate comes from, and make clients trust it.
- Read a `harbor.yml` for the Docker Compose installers.

The third topic is **the `harbor` command-line tool**. You will learn to:

- Sign the CLI in and know where it keeps credentials.
- Work with several servers and users through contexts.
- List projects, repositories and artifacts, and turn the output into JSON for scripts.

Everything is written for **Harbor 2.15.4** and the **Harbor CLI v0.0.27**.

## The words this course uses

The pages use Harbor's, the Open Container Initiative's (OCI) and Kubernetes' own terms, because those are the words you meet in the product, the logs and the documentation. Each term gets a short, plain definition the first time it appears on a page. A few terms come back on almost every page, so here they are up front.

A **registry** is a server that stores container images and other artifacts and serves them over HTTP. An **OCI artifact** is anything stored in the registry format of the Open Container Initiative: an image, a Helm chart, a signature. A **repository** is a named collection of artifacts, a **tag** is a movable name for one artifact, and a **digest** is the SHA-256 hash that names one artifact exactly. In Harbor, every repository lives in a **project**, which decides who may do what.

Three Harbor components come back on almost every page:

| Component | What it does |
| --- | --- |
| `core` | Harbor's API server; it checks users and signs the tokens the registry accepts |
| `registry` | Stores the content of every artifact |
| `nginx` | The entry point every client talks to |

## The example setup in your playground

Every playground and lab runs the same setup. Harbor runs in the namespace `harbor` and answers at `https://harbor.localtest.me:8443`. The administrator is `admin` with the lab-only password `Harbor12345`. A **workstation** pod holds the client tools, the `harbor` CLI, `regctl`, `oras`, `cosign`, `curl` and `jq`, and it trusts Harbor's certificate, so every Harbor command on a page runs there.

The example content is the podinfo application: its container image and its Helm chart, copied into the project `inventory`. Many labs start with something broken on purpose. That is the material, not a fault in the course.

## How the course is laid out

The course has three sections. It starts with how a running Harbor works, then how it is installed, and ends with the command-line tool you use every day.

| Section | What it covers |
| --- | --- |
| 010 | Harbor Architecture And OCI Artifacts |
| 020 | Installing Harbor With Helm And TLS |
| 030 | The Harbor Command-Line Tool |

Each section has one or more **modules**, and each module teaches one skill. A module brings together four kinds of material:

| What | What it is for | Graded? |
| --- | --- | --- |
| **Reading** | A short landing page, a few chapters that teach one idea each, and a summary | No |
| **Playground** | A small cluster on your own machine, to try everything you read | No |
| **Lab** | A cluster in a starting state, a task, and a grader that checks your work | Yes |
| **Capstone** | The last lab in a section, with several faults at once | Yes |

The best order is simple: read the chapters with the playground open next to them, take each lab when a chapter sends you to it, and finish each section with its capstone. The next part of this page explains how a module's pages guide you through that order.

## How to read a page

A module starts with a **landing page**. It says what the module teaches, what you should know first, and the order of its chapters. At the bottom of the landing page you start the module's playground, and you keep it running while you read.

The chapters (the parts of a module) read like the chapters of a technical book. Each one opens with the problem it solves, explains one idea in connected paragraphs, and closes with what you now know. The hands-on steps sit right in the text: a sentence or two on what to run and why, the command, and then what the result shows. Run each step in your playground as you reach it. You learn more from one real result than from a page of text.

Every chapter ends with a box of common pitfalls, the mistakes people make most often with what the chapter taught, and how to spot them. Now and then a page also has a tip box with a habit or shortcut you can use again, well beyond that page. The two boxes look like this:

> [!TIP]
> **A tip.** A habit or shortcut you can use again, well beyond this one page.

> [!WARNING]
> **Common pitfalls.** The mistakes people make most often with what you just learned, and how to spot them. Every chapter ends with one.

When a graded lab tests what a chapter taught, that chapter ends with a **Your mission** section. It tells you what the lab asks, then gives every command you need, in order: pause the playground with `astrona stop`, start the lab with `astrona run`, and send your work for grading with `astrona submit`. Solve the lab on your own before you look at its solution. When the lab is done, remove it with `astrona destroy` and start the playground again with `astrona start`, so you can carry on reading where you left off.

The last page of every module is the **Summary**. It sums up what you learned in a few short paragraphs, organised by idea. It also ends the module's hands-on work: the Summary page removes the playground, so your machine is clean before the next module.

One rule holds on every page. Code blocks are exactly what you type. Never change a command to make it "look right". If the result is different from what the page describes, that difference is the lesson.
