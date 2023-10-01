# `flatpaks` module for startingpoint

The `flatpaks` module can be used to install Flatpaks from Flathub on login. Flatpaks can either be installed system-wide or per-user. Previously-installed Flatpaks can also be removed.

## Example configuration

```yaml
- type: flatpaks
  system:
    install:
    - org.gnome.Loupe
    remove:
    - org.gnome.eog
  user:
    install:
    - org.gnome.Epiphany
    remove:
    - org.mozilla.firefox
```
