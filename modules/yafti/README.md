# `yafti`

The [`yafti`](https://github.com/ublue-os/yafti) module can be used to install [`yafti`](https://github.com/ublue-os/yafti) and set it up to run on first boot. Also `yafti`'s dependencies, `python3-pip` and `libadwaita` are installed.

Optionally, a list of Flatpak names and IDs can be included under `custom-flatpaks:`. These will be enabled by default under their own section on the Flatpak installation screen of `yafti`.

A default version of the `yafti` configuration file, `yafti.yml`, is supplied by this module. To make your own, create the file at `/usr/share/ublue-os/firstboot/yafti.yml`. The default version of the file can be found [here](https://github.com/ublue-os/bling/blob/main/modules/yafti/yafti.yml).