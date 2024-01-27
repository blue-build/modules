# bling

[![build-ublue](https://github.com/ublue-os/bling/actions/workflows/build.yml/badge.svg)](https://github.com/ublue-os/bling/actions/workflows/build.yml)

This repository containes modules to use in recipe.yml. See list of modules in [./modules](./modules/)

## Usage

You can add this to your Containerfile to copy the modules from this image over:
```dockerfile
COPY --from=ghcr.io/ublue-os/bling:latest /modules /tmp/modules/
```

## Verification

These images are signed with sisgstore's [cosign](https://docs.sigstore.dev/cosign/overview/). You can verify the signature by downloading the `cosign.pub` key from this repo and running the following command:
```sh
cosign verify --key cosign.pub ghcr.io/ublue-os/bling
```

## See what is in this image

### Raw commands

NOTE: This makes it so you need to extract everything from the base image!

```sh
podman save ghcr.io/ublue-os/bling:latest -o bling.tar
tar xf bling.tar && rm bling.tar
tar xf *.tar
```

This should extract the image in a way that you can see everything in it!

### Using [Dive](https://github.com/wagoodman/dive)

This method allows you to inspect the image through a TUI
```sh
dive ghcr.io/ublue-os/bling:latest
```
