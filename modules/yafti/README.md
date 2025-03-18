# `yafti`

The [`yafti`](https://github.com/ublue-os/yafti) module can be used to install Yafti and set it up to run on first boot. Yafti (Yet Another First Time Installer) is a GTK program by Universal Blue that is used for prompting the user of a custom image before doing some optional configuration such as installing Flatpaks.

Also Yafti's dependencies, `python3-pip` and `libadwaita` are installed.

Optionally, a list of Flatpak names and IDs can be included under `custom-flatpaks:`. These will be enabled by default under their own section on the Flatpak installation screen of `yafti`.

A default version of the `yafti` configuration file, `yafti.yml`, is supplied by this module. To make your own, create the file at `/usr/share/ublue-os/firstboot/yafti.yml`. The default version of the file can be found [here](https://github.com/blue-build/modules/blob/main/modules/yafti/yafti.yml).

## Known issues

Yafti autostart doesn't work on WMs (Window Managers) like Sway or Hyprland due to them not implementing XDG-Autostart specification.

https://github.com/swaywm/sway/issues/1423  
https://github.com/hyprwm/Hyprland/issues/5169

Usage of [dex](https://github.com/jceb/dex) in the affected WMs can be considered to mitigate this issue.
