# `akmods`

:::caution
Only Universal Blue based images are officially supported. Universal Blue builds with Fedora 38 & below are not supported. Custom kernels are not supported.
:::

The [`akmods`](https://github.com/ublue-os/akmods) module is a tool used for managing and installing kernel modules built by Universal Blue. It simplifies the installation of kernel modules, improving the capabilities of your system.

List of all available kernel modules are here:   
https://github.com/ublue-os/akmods/#features

Ublue-os-akmods-addons & ublue-os-nvidia-addons are already included when necessary, so they are not needed to install.

To use the `akmods` module, specify the kernel modules you wish to install in the `install:` section of your recipe/configuration file.

By default, the `akmods` module installs the `main` akmods for the `latest` version of Fedora.
`main` akmods are also compatible with other images, except `surface(-nvidia)` & `asus(-nvidia)`.

If you want to install akmods for `surface(-nvidia)` or `asus(-nvidia)` images, change `base` entry in the recipe file.
There is no need to specify `nvidia-version` tag if your image has Nvidia drivers already (hence, `-nvidia` suffix above).

See available tags here: https://github.com/ublue-os/akmods/#how-its-organized

Some images ship newest Nvidia drivers only, without option to use older Nvidia driver.  
If you want to install older version of the driver,   
Assure that your image is non-nvidia based & select driver version based on available tags above  
& input the driver version in `nvidia-version` recipe file entry. 

## Known issues

When the upstream base image is failing to build for some time, you will probably notice that this module fails too with this error:
```
Resolving dependencies...done
error: Could not depsolve transaction; 1 problem detected:
Problem: package "version_of_akmod" from @commandline requires "version_of_kernel", but none of the providers can be installed
- conflicting requests
```

Just wait for the base image build to resolve & akmods module will start working again.
If this issue happens for a prolonged period of time, report it to the upstream repo if not already reported or worked on.

