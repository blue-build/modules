> [!WARNING]  
> Only Universal Blue images as a base are officially supported. For other images, you'll likely need to do some more setup.

> [!WARNING]  
> Universal Blue builds with Fedora 38 & below are not supported.

> [!WARNING]  
> Custom kernels are not supported.

> [!IMPORTANT]  
> Be sure to use `-main`, `-nvidia`, `-surface(-nvidia)` or `-asus(-nvidia)` Universal Blue tagged image as a base if you want to use akmods.

# `akmods` Module for Startingpoint

The `akmods` is a tool used for managing and installing kernel modules. It simplifies the installation of kernel modules, improving the capabilities of your system.

List of all available kernel modules & versions/tags are here:
https://github.com/ublue-os/akmods

Ublue-os-akmods-addons & ublue-os-nvidia-addons are already included when necessary, so they are not needed to install.

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
`main` akmods are also compatible with `-nvidia` images. 

If you want to install akmods for `surface(-nvidia)` or `asus(-nvidia)` images, or for `older version of Fedora`, change this Containerfile content:

```
# Change this if you want different version/tag of akmods.
COPY --from=ghcr.io/ublue-os/akmods:main-39 /rpms /tmp/rpms
```
