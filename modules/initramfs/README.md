# `initramfs`

:::caution
This module is only supported for Fedora 41+ images.
:::

The `initramfs` module is used to regenerate initramfs, needed for some boot modifications to apply.

If you modify something related to kernel or boot, but you don't see any changes applied to the system, this is likely the module that you need to use.

You need to regenerate initramfs at least when doing any of the following:
- modifying `modprobe.d` config files
- modifying `modules-load.d` config files
- modifying `dracut.conf.d` config files
- customizing `plymouth` theming
- other unknown modifications

It is recommended to set this module as one of the last in module execution order, to ensure that initramfs regeneration will cover all modifications that you did.

:::note
Client-side initramfs regeneration like `rpm-ostree initramfs` & `rpm-ostree initramfs-etc` are for local-users only & not to be confused with this module's build-time initramfs regeneration.
This module regenerates the system initramfs during the build process, while `rpm-ostree initramfs` & `rpm-ostree initramfs-etc` regenerate the local initramfs on top of the system one every update on the local-user's system.
:::
