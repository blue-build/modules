# `gschema-overrides`

The `gschema-overrides` module can be used for including system-setting overrides for GTK-based desktop environments.
GTK-based desktop environments include Gnome, Cinnamon, MATE, Budgie & such.
This module is similar to using `dconf` configuration, but is better because it doesn't require a systemd service & supports build-time troubleshooting.

What does this module do?

- It copies all content from `/usr/share/glib-2.0/schemas`, except existing gschema.overrides to avoid conflicts, into temporary test location.
- It copies your gschema.overrides you provided in this module from `config/gschema-overrides` into temporary test location.
- It tests them for errors in temporary test location by using `glib-compile-schemas` with `--strict` flag. If errors are found, build will fail.
- If test is passed successfully, it copies your gschema.overrides to `/usr/share/glib-2.0/schemas`.
- It compiles gschema using `glib-compile-schemas` in `/usr/share/glib-2.0/schemas` location to include your changes.

Temporary test location is:

`/tmp/bluebuild-schema-test`

## Usage

To use this module, you need to include your gschema.override file(s) in this location (make folder if it doesn't exist):

`config/gschema-overrides`

Then you need to include those file(s) in recipe file, like in example configuration.

It is highly recommended to use `zz1-` prefix before your gschema.override name, to ensure that your changes are going to be applied.

Also don't forget to rename your file(s) too with this prefix in `config/gschema-overrides`.

## Creating gschema.override files

Gschema.override files use `gsettings` keyfile format for settings output.

### Example of gschema.override settings
```
[org.gnome.desktop.peripherals.touchpad]
tap-to-click=true

[org.gnome.settings-daemon.plugins.power]
power-button-action='interactive'

[org.gnome.mutter]
check-alive-timeout=uint32 20000

[org.gnome.shell.extensions.blur-my-shell]
sigma=5
```

### Example of gschema.override lockscreen settings (Gnome)
```
[org.gnome.desktop.peripherals.touchpad:GNOME-Greeter]
tap-to-click=true
```

- To gather setting change after you input the command, use this:

  `dconf watch /`

  When you change some setting toggle or option when this command is active,   
  you will notice that command will output the key for the changed setting,   
  which you can use & write into gschema.override file in the format shown in example above.

- To gather current & available settings on booted system, you can use this command:
  
  `gsettings list-recursively`
  
  You should use this command everytime when you want to apply some setting override,
  to ensure that it's listed as available.

**Gschema.override files don't support relocatable schemas & locking settings.**

To add overrides for schemas not supported by gschema overrides, you can use the `dconf-update-service` from the `bling` module.

- To gather a list of relocatable schemas, use this command:

  `gsettings list-relocatable-schemas`.

### Example of relocatable schemas
```
[org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0]
binding='<Shift><Alt><Super>s'
command='systemctl suspend'
name='Suspend'
```
