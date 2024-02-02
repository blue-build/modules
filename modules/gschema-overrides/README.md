# `gschema-overrides` module for BlueBuild

The `gschema-overrides` module can be used for including system-setting overrides for GTK-based desktop environments.
GTK-based desktop environments include Gnome, Cinnamon, MATE, Budgie & such.
This module is similar to using `dconf` configuration, but is better because it doesn't require a systemd service & supports build-time troubleshooting.

What does this module do?

- It copies all content from `/usr/share/glib-2.0/schemas`, except existing gschema.overrides to avoid conflicts, into temporary test location.
- It copies your gschema.overrides you provided in this module from `/usr/share/glib-2.0/schemas` into temporary test location.
- It tests them for errors in temporary test location by using `glib-compile-schemas` with `--strict` flag. If errors are found, build will fail.
- If test is passed successfully, compile gschema using `glib-compile-schemas` in `/usr/share/glib-2.0/schemas` to include your changes.

Temporary test location is:

`/tmp/bluebuild-schema-test`

To use this module, you need to include your gschema.override file(s) in this location:

`/usr/share/glib-2.0/schemas`

Then you need to include those file(s) in recipe file, like in example configuration.

It is highly recommended to use `z1-` prefix before your gschema.override name, to ensure that your changes are going to be applied.

Also don't forget to rename your file(s) too with this prefix in `/usr/share/glib-2.0/schemas`.

## Example configuration

```yaml
type: gschema-overrides
include:
  - z1-myoverride.gschema.override
  - z1-myoverride2.gschema.override
```

For more information on best practices for editing `gschema.override` files & potentially combining them with `dconf`, here's some documentation:

https://github.com/ublue-os/bling/issues/53#issuecomment-1915474038
