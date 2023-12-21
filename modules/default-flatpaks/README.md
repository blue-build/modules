# `default-flatpaks` module for startingpoint

The `default-flatpaks` module can be used to install or uninstall flatpaks from a configurable remote on every boot. It skips that operation if no changes are detected. This module first removes the Fedora Flatpaks remote and Flatpaks that come pre-installed in Fedora. A Flatpak remote is configured the first time the module is used, but it can be re-configured in subsequent usages of the module. If no Flatpak remote is specified, the module will default to using Flathub.

Flatpaks can either be installed system-wide or per-user, though per-user flatpaks will be installed for every user on a system. Previously-installed flatpaks can also be removed.

The module uses the following scripts to handle flatpak setup:

- `/usr/bin/system-flatpak-setup`
- `/usr/bin/user-flatpak-setup`

The scripts are run on every boot by these services:

- `/usr/lib/systemd/system/system-flatpak-setup.service`
- `/usr/lib/systemd/user/user-flatpak-setup-service`

`system-flatpak-setup` checks the flatpak repo information and install/remove lists created by the module. `user-flatpak-setup` functions the same for user flatpaks.

This module stores the Flatpak remote configuration and Flatpak install/remove lists in `/etc/flatpak/`. There are two subdirectories, `user` and `system` corresponding with the install level of the Flatpaks and repositories. Each directory has text files containing the IDs of flatpaks to `install` and `remove`, plus a `repo-info.yml` containing the details of the Flatpak repository.

This module also supports disabling & enabling notifications.

## Example configurations

```yaml
type: default-flatpaks
notifications:
  # Send notification after install/uninstall is finished (true/false)
  notify: true
system:
  # If no repo information is specified, Flathub will be used by default
  repo-url: https://dl.flathub.org/repo/flathub.flatpakrepo
  repo-name: flathub
  repo-title: "Flathub (system-wide)" # Optional; this sets the remote's user-facing name in graphical frontends like GNOME Software
  install:
    - org.gnome.Loupe
  remove:
    - org.gnome.eog
# A flatpak repo can also be added without having to install flatpaks,
# as long as one of the repo- fields is present
user:
  repo-name: flathub
```

```yaml
# Assuming that the above example is called first in a recipe,
# a subsequent usage might look like this:
type: default-flatpaks
system:
  # If the repo-* fields are omitted, the configured repo will
  # use the previous configuration. Otherwise, it defaults to Flathub.
  install:
    - org.kde.kdenlive
user:
  # repo-name will overwrite the previously-configured repo-name for the user remote
  repo-name: flathub-user
  repo-title: "Flathub (User)
```
