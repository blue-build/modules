# `akmods`

:::caution
Only Universal Blue based images are officially supported. Universal Blue builds with Fedora 38 & below are not supported. Custom kernels are not supported.
:::

The [`akmods`](https://github.com/ublue-os/akmods) module is a tool used for managing and installing kernel modules built by Universal Blue. It simplifies the installation of kernel modules, improving the capabilities of your system.

List of all available kernel modules & versions/tags are here:   
https://github.com/ublue-os/akmods

Ublue-os-akmods-addons & ublue-os-nvidia-addons are already included when necessary, so they are not needed to install.

To use the `akmods` module, specify the kernel modules you wish to install in the `install:` section of your recipe/configuration file.

By default, the `akmods` module installs the `main` version of akmods.
`main` akmods are also compatible with other images, except `surface(-nvidia)` & `asus(-nvidia)`.

If you want to install akmods for `surface` or `asus` images, change `base` entry in the recipe file.

See available tags here: https://github.com/ublue-os/akmods/#how-its-organized

## Known issues

### Outdated akmods compared to the current kernel version fail the build

When the upstream base image is failing to build for some time, you will probably notice that this module fails too with this error:
```
Resolving dependencies...done
error: Could not depsolve transaction; 1 problem detected:
Problem: package "version_of_akmod" from @commandline requires "version_of_kernel", but none of the providers can be installed
- conflicting requests
```

Just wait for the base image build to resolve & akmods module will start working again.
If this issue happens for a prolonged period of time, report it to the upstream repo if not already reported or worked on.

### Some akmods are not installing due to lack of some additional akmod package

Example of the error:
```
Resolving dependencies...done
error: Could not depsolve transaction; 1 problem detected:
Problem: conflicting requests
- nothing provides kvmfr-kmod-common >= 0.0.git.21.ba370a9b needed by kmod-kvmfr-6.9.4-200.fc40.x86_64-0.0.git.21.ba370a9b-1.fc40.x86_64 from @commandline
```

This happens when the mentioned akmod is not pulled from ublue-os/akmods COPR repo, but from some other one.  
Those akmods are rare & they are residing in `extra` akmods stream.  
There is also the information of repo source of the akmod, where you can see which akmod is the "exotic" one.  
All this information can be seen in [`akmods` repo](https://github.com/ublue-os/akmods#kmod-packages).

The solution to this problem is to add the affected akmod repo to [`rpm-ostree`](https://blue-build.org/reference/modules/rpm-ostree/) module in `repos` section.
