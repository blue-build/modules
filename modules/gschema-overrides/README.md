# `gschema-overrides` module for startingpoint

`Gschema-overrides` startingpoint module is used for including your system-setting overrides.
If you heard about `dconf`, this is similar to it, but it's a much better & cleaner method of doing it.

What does this module do?

- It copies all content from `/usr/share/glib-2.0/schemas`, except existing gschema.overrides to avoid conflicts, into temporary test location.
- It copies your gschema.overrides you provided in this module from `/usr/share/glib-2.0/schemas` into temporary test location.
- It tests them for errors in temporary test location by using `glib-compile-schemas` with `--strict` flag. If errors are found, build will fail.
- If test is passed successfully, compile gschema using `glib-compile-schemas` in `/usr/share/glib-2.0/schemas` to include your changes.

Temporary test location is:

`/tmp/bluebuild-schema-test`

To use it, you need to include your gschema.override file(s) in this location:

`/usr/share/glib-2.0/schemas`

Then you need to include it in recipe file, like in example configuration.

It is highly recommended to use `z0-` prefix or higher before your gschema.override name, to ensure that your changes are going to be applied.

## Example configuration

```yaml
type: gschema-overrides
include:
  - z0-myoverride.gschema.override
  - z0-myoverride2.gschema.override
```

For more information on best practices for editing `gschema.override` files & potentially combining them with `dconf`, here's some documentation:

https://github.com/ublue-os/bling/issues/53#issuecomment-1915474038
