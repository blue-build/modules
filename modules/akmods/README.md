> [!WARNING]  
> Only Universal Blue images as a base are officially supported. For other images, you'll likely need to do some more setup.

> [!WARNING]  
> Universal Blue builds with Fedora 38 & below are not supported.

> [!WARNING]  
> Custom kernels are not supported.

> [!IMPORTANT]  
> Use `-nvidia`, `-surface`, `-asus` etc. Universal Blue tagged images as a base if you want those akmods.

# `akmods` Module for Startingpoint

The `akmods` is a tool used for managing and installing kernel modules. It simplifies the installation of kernel modules, improving the capabilities of your system.

List of all available kernel modules & versions/tags are here:
https://github.com/ublue-os/akmods

Ublue-os-akmods-addons & ublue-os-nvidia-addons are already included as necessary, so they are not needed to install.

To use `akmods` module, specify the kernel modules you wish to install in the `install:` section of your recipe/configuration file.

## Example configuration
```yaml
type: akmods

install:
    - openrazer
    - openrgb
    - v4l2loopback
    - winesync
```
 
By default, `akmods` module is installing the `main` akmods for `latest` version of Fedora.

If you want to install akmods for `older version of Fedora`, change this Containerfile content:

```
# Change this if you want different version of akmods. Only use main akmod tag.
COPY --from=ghcr.io/ublue-os/akmods:main-39 /rpms /tmp/rpms
```
