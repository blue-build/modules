# `bling`

The `bling` module can be used to pull in small "bling" into your image. Bling is stuff that doesn't necessitate being configured at build time, in the form of configuration files or program installers.

The bling to pull in is declared under `install:`, and the code for installing them is all in simple named scripts under the `installers/` directory. The basic code for the `bling` module is very similar to the code of the `script` module.

## Submodule documentation

### `dconf-update-service`

The `dconf-update-service` submodule creates a systemd unit to automatically update changes you make to [dconf](https://wiki.gnome.org/Projects/dconf) in your custom image.

For an example of a dconf keyfile, see the [dconf custom defaults documentation](https://help.gnome.org/admin/system-admin-guide/stable/dconf-custom-defaults.html.en).

Take a note that this documentation is for local-users, not for custom image maintainers. But it serves as a good example of what dconf file looks like.  
Ignore the advice about creating the `user` profile, as it's already present & just place dconfs in `/etc/dconf/db/distro.d/`, not in `local.d` folder ([Thinking like a distribution](https://blue-build.org/learn/mindset/) mindset).

**Unlike the `gschema-overrides` module, dconf keyfiles are not checked at compile time for errors.**

### `ublue-update`

This was the default system & applications updater for Universal Blue images.

However, it's deprecated & Universal Blue migrated to `uupd`:  
https://github.com/ublue-os/uupd

Use it with a caution, knowing it's an unmaintained program.
