# `bling`

The `bling` module can be used to pull in small "bling" into your image. Bling is stuff that doesn't necessitate being configured at build time, in the form of configuration files or program installers.

The bling to pull in is declared under `install:`, and the code for installing them is all in simple named scripts under the `installers/` directory. The basic code for the `bling` module is very similar to the code of the `script` module.

## Submodule documentation

### `dconf-update-service`

The `dconf-update-service` submodule creates a systemd unit to automatically update changes you make to [dconf](https://wiki.gnome.org/Projects/dconf) in your custom image. For an example of a dconf keyfile, see the [dconf custom defaults documentation](https://help.gnome.org/admin/system-admin-guide/stable/dconf-custom-defaults.html.en).

**Unlike the `gschema-overrides` module, dconf keyfiles are not checked at compile time**
