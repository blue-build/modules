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
