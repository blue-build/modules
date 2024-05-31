# brew

The brew module installs [Homebrew (Brew)](https://brew.sh/) on your system and ensures the package manager remains updated and maintained. This module sets up systemd services to periodically update and upgrade the installed Brew packages.

## Features
- Installs Brew at build-time.
- Sets up systemd services to update the Brew binary to the latest version.
- Sets up systemd services to upgrade Brew packages automatically.
- Options to control the frequency of updates and upgrades.

## Configuration Options

### `update-interval` (optional: string, default: '6h')
Defines how often the Brew update service should run. The string is passed directly to `OnUnitInactiveSec` in systemd timer. (Syntax: ['1d', '6h', '10m']).

### `upgrade-interval` (optional: string, default: '8h')
Defines how often the Brew upgrade service should run. The string is passed directly to `OnUnitInactiveSec` in systemd timer. (Syntax: ['1d', '6h', '10m']).

### `wait-after-boot-update` (optional: string, default: '10min')
Time delay after system boot before the first Brew update runs. The string is passed directly to `OnBootSec` in systemd timer. (Syntax: ['1d', '6h', '10m']).

### `wait-after-boot-upgrade` (optional: string, default: '30min')
Time delay after system boot before the first Brew package upgrade runs. The string is passed directly to `OnBootSec` in systemd timer. (Syntax: ['1d', '6h', '10m']).

### `auto-update` (optional: boolean, default: true)
If false, disables automatic activation of `brew-update.timer`.

### `auto-upgrade` (optional: boolean, default: true)
If false, disables automatic activation of `brew-upgrade.timer`.

!!! warning
    Please review the brew documentation carefully before modifying these settings.

### `nofile-limits` (optional: boolean, default: false)
Determines whether to apply nofile limits for Brew installations. When set to true, it increases the nofile limits to prevent certain packages from failing due to file limits. However, it's important to note that increasing nofile limits can have potential security implications. Defaults to false for security purposes.

### `brew-analytics` (optional: boolean, default: true)
Determines whether to opt-out of Brew analytics. When set to true, analytics are enabled.

## Development
Setting `DEBUG=true` inside `brew.sh` will enable additional output for debugging purposes during development.

## Uninstallation

When excluding `brew` module from the recipe, it's not enough to get it removed.  
On booted system, it's also necessary to run the official `brew` uninstalation script & to delete folders created by tmpfiles.d.

This happens, because Brew installs itself in `/var/home/` by default, which is not possible to include or remove in the image, since it is considered as per-machine state directory (like whole `/var/` & its subdirectories).  
But, we made it possible to install `brew` inside the image through a hack, by making `/var/roothome/` (`/root/` is a symlink to it) & tricking official Brew installation script that it's not run as root, while installing it there.  
It is indeed mentioned in [`files` module documentation](https://blue-build.org/reference/modules/files/) that copying files to `/var/` is not possible in build-time, but we somehow managed to make it work in this case (big thanks to Bluefin maintainer [m2giles](https://github.com/m2Giles), who made this module possible).  
As a consequence, automatic uninstallation by `rpm-ostree` is not possible, as explained in 1st sentence of this paragraph.

Either local-user can execute this script manually or image-maintainer can make it automatic through systemd service.

Uninstallation script:  
```
#!/usr/bin/env bash

# Official Brew uninstaller
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"

# Remove folders created by tmpfiles.d
if [[ -d "/var/lib/homebrew" ]]; then
  echo "Removing /var/lib/homebrew/ directory"
  sudo rm -r /var/lib/homebrew
else
  echo "/var/lib/homebrew/ directory is already removed"
fi
if [[ -d "/var/cache/homebrew" ]]; then
  echo "Removing /var/cache/homebrew/ directory"
  sudo rm -r /var/cache/homebrew
else
  echo "/var/cache/homebrew/ directory is already removed"
fi
if [[ -d "/var/home/linuxbrew" ]]; then
  echo "Removing /var/home/homebrew/ directory"
  sudo rm -r /var/home/linuxbrew
else
  echo "/var/home/homebrew/ directory is already removed"
fi
```
