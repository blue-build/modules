# `initramfs`

The `initramfs` module is used to regenerate initramfs, needed for some boot modifications to apply.

If you modify something related to kernel or boot, but you don't see any changes applied to the system, this is likely the module that you need to use.

Known modifications which require use of this module are:
- `modprobe.d` config files
- `modules-load.d` config files
- `dracut.conf.d` config files
- `plymouth` theming
- other unknown modifications

It is recommended to set this module to be one of the last in module execution order, to assure that initramfs regeneration will cover all modifications that you did.
