# bling

[![build-ublue](https://github.com/ublue-os/bling/actions/workflows/build.yml/badge.svg)](https://github.com/ublue-os/bling/actions/workflows/build.yml)

A layer for extras and more bling for your image

# Contains

- A nix installer
- Multiple fonts
- Devpod
- Justfiles
- Yafti files
- External repository files
- Other `(TO BE DONE)`

# Usage

You can add this to your Containerfile to copy anything from this image over:

    COPY --from=ghcr.io/ublue-os/bling:latest /files/usr/bin/ublue-nix-installer /
    COPY --from=ghcr.io/ublue-os/bling:latest /files/usr/bin/ublue-nix-uninstaller /

To use all fonts:

    COPY --from=ghcr.io/ublue-os/bling:latest /files/usr/share/fonts /path/to/fonts

To use only Inter do:

    COPY --from=ghcr.io/ublue-os/bling:latest /files/usr/share/fonts/inter /path/to/fonts/inter

We also want to package all these modifications as RPM packages for easier installation. `(TO BE DONE)`

# Verification

These images are signed with sisgstore's [cosign](https://docs.sigstore.dev/cosign/overview/). You can verify the signature by downloading the `cosign.pub` key from this repo and running the following command:

    cosign verify --key cosign.pub ghcr.io/ublue-os/bling
