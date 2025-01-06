# `initramfs`

:::caution
This module is only supported for Fedora 41+ images.
:::

The `initramfs` module is used to regenerate initramfs, which is the temporary file system loaded into RAM, as part of the early Linux startup process, used by many things happening during boot. 

If you are trying to modify something related to the kernel or boot sequence (such as plymouth), but you don't see any changes applied to the system, you'll likely need to use this module.

You need to regenerate initramfs at least when doing any of the following:
- modifying `modprobe.d` config files
- modifying `modules-load.d` config files
- modifying `dracut.conf.d` config files
- customizing `plymouth` theming
- other unknown modifications

You only need to run the regeneration once per build, not separately for each modification requiring it. It is recommended to set this module as one of the last in your recipe, to ensure that initramfs regeneration will cover all the modifications done before it.

:::note
Client-side initramfs regeneration like `rpm-ostree initramfs` & `rpm-ostree initramfs-etc` are for local-users only & not to be confused with this module's build-time initramfs regeneration.
This module regenerates the system initramfs during the build process, while `rpm-ostree initramfs` & `rpm-ostree initramfs-etc` regenerate the local initramfs on top of the system one every update on the local-user's system.
:::
