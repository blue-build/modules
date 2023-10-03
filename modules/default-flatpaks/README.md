# `default-flatpaks` module for startingpoint

The `default-flatpaks` module can be used to install flatpaks from a configurable remote on first boot. Flatpaks can either be installed system-wide or per-user, though per-user flatpaks will be installed for every user on a system. Previously-installed flatpaks can also be removed.

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
    repo-url: https://dl.flathub.org/repo/flathub.flatpakrepo
    repo-name: flathub
    install:
    - org.gnome.Epiphany
    remove:
    - org.mozilla.firefox
```
