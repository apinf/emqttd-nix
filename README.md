# Nix expressions for emqttd

This repo contains nix-expressions to build emqttd and a docker image for it in a deterministic manner.

# Usage

Ensure [nix][] is installed, and run

`nix-build` to build emqttd. This version is expected to be run in a container.

## Docker image

`nix-build docker.nix` will build a docker image. Note that this does not require docker to be installed on the machine.

A path that looks similar to
`/nix/store/inxac5930nz66gsx64wvx8hh78bfaayv-docker-image-apinf-emqttd.tar.gz`
will be printed at the end, if the build was succesful.  This is an archive in
the `docker save` format, and can be transferred to the production machines or
distributed using container registries.

To load the image into a local docker daemon, run `docker load -i <path-to-image>`.

The image expects hostnames `elasticsearch` and `postgres` to resolve to the respective services.

[nix]: https://nixos.org/nix/

## Docker compose

The version of emqttd bundled here has elasticsearch logger and auth_pgsql modules enabled. To run everything together,
a compose file is provided for convenience. With `docker-compose` installed, run

```
cd docker-compose
docker-compose up
```

This will also run elasticsearch and postgresql populated with default values.
Note that there may be start order issues at times, we are working on improving
appropriate waiting and retry strategies.

To prevent startup order issues, you can run

```
docker-compose up postgres
docker-compose up elasticsearch
docker-compose up emqttd
```

# Testing

There is no automated end to end test suite (yet). To verify if everything
works as expected, install an mqtt client and publish and/or subscribe to
emqttd.

Verify the following:

 - Access control rules set in postgres database must be honored for publish/subscribe.
 - Events corresponding to various phases in mqtt workflow should be logged to Elasticsearch.

When running from docker compose, the testing must happen in containers
connected to the same network, or with ports exposed to host to prevent
connectivity issues.

# FAQ

## Why is this necessary?

### Short answer

We need a way to build emqttd in a deterministic manner, with strong assurance
that simply repeating the build won't result in a wildly different result.

### Long answer

A simple make in `emq-relx` repository will build emqttd, and there is a
helpful `emq-docker` repo to build a docker image.  However, there is no
guarantee that if the build is repeated, the results are functionally
identical.

Erlang ecosystem has a dependency problem.  Semantic versioning was not around
when a majority of projects were written.  Most projects still use source
dependencies, often referring to a git branch or tag instead of an sha.  Lock
files were unheard of until rebar3 or mix, but many projects still use
erlang.mk or rebar.

As a result, it is possible (and not very uncommon) for two builds made at
different points of time to use different source versions of certain
dependencies altogether.  Most of the time the updates may be
backwards-compatible, but it can be frustrating to have to hunt down the
changes.

Commonly packages are deployed in compiled form, exact versions of sources are
not recorded.  When an issue is encountered in production, there is no fool
proof way to identify the corresponding source.

In addition, erlang package namespace is global. i.e; there can only be one
version of a package loaded into the erlang VM at any point of time. (Ignoring
hot code upgrades). However global dependency resolution is a relatively new
feature introduced with rebar3 and mix, both of which are not widely adopted.
This can result in multiple copies of the same dep being pulled and compiled
during a typical build.

All of this results in a lot of headache when trying to debug issues in
production.  Not being able to reproduce a build is silly. It is an
unforgivable sin to ship products that can not be reliably rebuilt from source.

## How does this work?

[Nix][nix] is a functional package manager. To quote <https://nixos.org/nix>:

> Nix is a powerful package manager for Linux and other Unix systems that makes
> package management reliable and reproducible.

The internals of nix are out of scope here, and are described in detail in the
documentation.

We just asked nix to build the dependencies and finally emqttd and the docker image.

The builds are repeatable since expected git revisions and the hashes of sources
are tracked in the repository. The expressions allow building everything
(including erlang, bash, gcc etc) from source in a predictable manner.

## Why is the docker image so large?

The smallest image can probably be made in under 20MB, whereas the images built
using this repo are a little over half a GB in size. This is due to a few reasons:

1. Some nix expressions we use are very conservative and include all possible
   dependencies. This increases the closure size.
2. The entire build closure is included in the image. This includes the exact
   erlang version, the exact bash version, sources of erlang deps, etc. Most of
   this is not strictly necessary, however, having this around does not
   particularly hurt.
3. The lean image uses musl libc whereas we use glibc. This alone makes a huge
   difference, and replacing it takes some effort.

We believe the increased size is worth the benefits of reproducible builds,
when storage is relatively cheap. We will consider replacing glibc with musl
libc to reduce the size if it becomes a pressing issue.

## Won't updating the release be difficult?

Updating the release requires each dependency to be carefully considered, and
its derivation to be updated. This is a _good_ thing.

Updating the revisions and hashes can be automated with some effort, and the
resulting workflow can be made as simple as that of working with similar
locking and verifying package managers and build systems, for example yarn.
