# `akmods` Module for Startingpoint

The `akmods` is a tool used for managing and installing kernel modules. It simplifies the installation of kernel modules, improving the capabilities of your system.

List of all available kernel modules & versions/tags are here: https://github.com/ublue-os/akmods

To use `akmods` module, specify the akmods tag in Containerfile
(line already exists at the 2nd last paragraph, you just need to adjust it):

`# Starting with Fedora 39, the main image does not contain kmods
COPY --from=ghcr.io/ublue-os/akmods:SPECIFY-YOUR-TAG-HERE /rpms /tmp/rpms`

After that, specify kernel modules you wish to install in the `install:` section of your recipe/configuration file.

## Example configuration
```yaml
type: akmods

install:
    - openrazer
    - openrgb
    - v4l2loopback
    - winesync
```

## Notes

It should be used for Fedora 39 & above only.
For Nvidia, use Universal Blue base Nvidia images + akmod builds with regular tag.
Only Universal Blue base images are officially supported.
Custom kernels are not supported.
