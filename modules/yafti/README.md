# [`yafti`](https://github.com/ublue-os/yafti) Module for Startingpoint

If included, the `yafti` module will install `yafti` and set it up to run on first boot. Also `yafti`'s dependencies, `python3-pip` and `libadwaita` are installed

Optionally, a list of Flatpak names and IDs can be included under `custom-flatpaks:`. These will be enabled by default under their own section on the Flatpak installation screen of `yafti`.

The main `yafti` configuration file, `yafti.yml`, is in `/usr/share/ublue-os/firstboot/yafti.yml` and can be edited for a more custom first-boot experience.

## Example configuration

```yaml
type: yafti
custom-flatpaks:
    - Celluloid: io.github.celluloid_player.Celluloid
    - Krita: org.kde.krita
```
