# `default-flatpaks`

:::note
For instructions on migration from v1 to v2, see the [announcement blog post](/blog/default-flatpaks-v2).
:::

The `default-flatpaks` module can be used to install Flatpaks from a configurable remote on every boot. By default the module will remove the Fedora Flatpak remote and install the Flathub remote, but you can also configure it to install other Flatpaks from other remotes.

## Features

- System and user systemd services that are based on your configuration
  - Set up a Flatpak remote
  - Install Flatpaks from the remote
- CLI tool `bluebuild-flatpak-manager` to
  - Display the Flatpak configurations in the image
  - Manually initiate the setup of Flatpaks
  - Disable the automatic Flatpak setup
  - Re-enable the automatic Flatpak setup
  - _run the `bluebuild-flatpak-manager` command for help and documentation_

## Configuration

The `default-flatpaks` module configuration is based on a list of `configurations:` that each set a scope to install in (`system` or `user`), a Flatpak repository to set up, and a list of Flatpaks to install from the repository.

Multiple configurations are supported, and subsequent module calls will append new configurations to the list. Overriding previous configurations is currently not supported.

### Scope

The `scope:` property can be set to `system` or `user`. If omitted, the default is `user`. This property determines whether the Flatpak repository and packages are set up for the system or for each user separately.

For a single-user system, you can safely use the `user` scope, since that will allow installation of Flatpaks from the configured repo and management of the installed Flatpaks without authentication. If you have multiple users for whom you want to set up the same system Flatpaks, you should use the `system` scope. This ensures that the Flatpaks are not duplicated in each user's home directory, and that managing the Flatpaks requires admin permissions.

### Flatpak repository

The `repo:` property is used to configure the Flatpak repository to set up. If omitted, Flathub will be used by default. The URL should be a link to a `.flatpakrepo` file. The name and title are used to identify the repository in the Flatpak CLI; the name should be lowercase and not contain spaces, while the title can be any string.

### Notification

The `notify:` property can be set to `true` or `false`. If omitted, the default is `true`. This will send a notification on each boot to the user(s) when starting the Flatpak installation and when it is finished.

### Flatpak installation

The `install:` property is a list of the Flatpak IDs to install from the configured repository. If omitted, no Flatpaks will be installed, but the Flatpak repository will still be set up. If the repository to use is configured as Flathub, the list of Flatpaks will be validated at build time to ensure that the packages are available on Flathub.
