Static container registry
=========================

This repository contains tools to maintain a static container registry using
[nerdctl](https://github.com/containerd/nerdctl), a Docker-compatible CLI for
[containerd](https://containerd.io/).

It targets an AWS-compatible S3 storage account.

It represents the _path of least resistance_ on my setup.


Alternatives
------------

Jérôme Petazzoni's [registrish](https://github.com/jpetazzo/registrish) uses
[skopeo](https://github.com/containers/skopeo) to extract image data and
supports additional targets. I don't use Docker and therefore couldn't use the
`docker-daemon` scheme with skopeo to work with local images.


Setup
-----

Install the [AWS CLI](https://docs.aws.amazon.com/cli/index.html)
command-line tools. On MacOS you can use the
[awscli](https://formulae.brew.sh/formula/awscli) Homebrew formula.

Clone this repository or copy the main branch into your current working
directory using:
```bash
curl -L https://github.com/malthe/static-container-registry/tarball/main | \
    tar --strip-components=1 -xz
```

Usage
-----

The starting point is to build or pull down an image locally.

For example, we can pull down Google's hello world example. For
convenience and because the upload script relies on them, we'll define
environment variables `IMAGE` and `TAG` first:
```bash
$ export IMAGE=gcr.io/google-samples/node-hello TAG=1.0
$ nerdctl pull $IMAGE:$TAG
```

Save (export) this image to a temporary directory:
```bash
$ mkdir tmp
$ nerdctl save $IMAGE:$TAG | tar xv -C tmp
```

Define the following environment variables to prepare for the upload.
```bash
$ export AWS_ACCESS_KEY_ID=<access-key-id>
$ export AWS_SECRET_ACCESS_KEY=<secret-access-key>
```

If using a non-AWS service such as [DigitalOcean
Spaces](https://www.digitalocean.com/products/spaces), additionally
set the region and endpoint:
```bash
$ export AWS_DEFAULT_REGION=<region>
$ export ENDPOINT=--endpoint-url https://$AWS_DEFAULT_REGION.digitaloceanspaces.com
```

That's it. We are ready to upload:
```bash
$ ( cd tmp ; ../upload.sh )
```

You can confirm that the registry was prepared correctly by pulling
down the image. The exact image name will depend on which S3 service
you're using.
```bash
$ nerdctl pull $BUCKET.$AWS_DEFAULT_REGION.digitaloceanspaces.com/$IMAGE:$TAG
```

