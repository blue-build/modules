# `default-flatpaks` module for startingpoint

The `default-flatpaks` module removes the Fedora Flatpaks remote that comes pre-installed by Fedora, and can be used to install flatpaks from a configurable remote on first boot. Flatpaks can either be installed system-wide or per-user, though per-user flatpaks will be installed for every user on a system. Previously-installed flatpaks can also be removed.

The module uses the following scripts to handle flatpak setup:

- `/usr/bin/system-flatpak-setup`
- `/usr/bin/user-flatpak-setup`

The scripts are run on first boot and login by these services:

- `/usr/lib/systemd/system/system-flatpak-setup.service`
- `/usr/lib/systemd/user/user-flatpak-setup-service`

`system-flatpak-setup` checks the flatpak repo information and install/remove lists created by the module. It also checks for the existence of `/etc/ublue-os/system-flatpak-configured` before running. `user-flatpak-setup` functions the same for user flatpaks, but checks for `$HOME/.config/ublue-os/user-flatpak-configured` instead.

Flatpak setup can be run again by removing `/etc/ublue-os/system-flatpak-configured` for system-wide flatpaks, or `$HOME/.config/ublue-os/user-flatpak-configured` for user flatpaks.

## Example configuration

```yaml
- type: default-flatpaks
  system:
    repo-url: https://dl.flathub.org/repo/flathub.flatpakrepo
    repo-name: flathub
    repo-title: "Flathub (system-wide)" # Optional; this sets the remote's user-facing name in graphical frontends like GNOME Software
    install:
    - org.gnome.Loupe
    remove:
    - org.gnome.eog
  user:
    # A flatpak repo can also be added without having to install flatpaks
    repo-url: https://dl.flathub.org/repo/flathub.flatpakrepo
    repo-name: flathub
```
