# brew

The brew module installs Homebrew (Brew) on your system and ensures the package manager remains updated and maintained. This module sets up systemd services to periodically update and upgrade the installed Brew packages.

## Features
- Installs Brew at build time.
- Configures and installs specified Brew packages.
- Sets up systemd services to update Brew packages automatically.
- Sets up systemd services to upgrade the Brew binary to the latest version.
- Options to control the frequency of updates and upgrades.

## Configuration Options

### `packages` (required: list of strings)
A list of Brew packages to be installed. This is a mandatory configuration and must be provided.

### `update_interval` (optional: string, default: '6h')
Defines how often the Brew update service should run. The string is passed directly to `OnUnitInactiveSec` in systemd timer. (Syntax: ['1d', '6h', '10m']).

### `upgrade_interval` (optional: string, default: '8h')
Defines how often the Brew upgrade service should run. The string is passed directly to `OnUnitInactiveSec` in systemd timer. (Syntax: ['1d', '6h', '10m']).

### `wait_after_boot_update` (optional: string, default: '10min')
Time delay after system boot before the first Brew update runs. The string is passed directly to `OnBootSec` in systemd timer. (Syntax: ['1d', '6h', '10m']).

### `wait_after_boot_upgrade` (optional: string, default: '30min')
Time delay after system boot before the first Brew package upgrade runs. The string is passed directly to `OnBootSec` in systemd timer. (Syntax: ['1d', '6h', '10m']).

### `auto_update` (optional: boolean, default: true)
If true, disables automatic activation of `brew-update.timer`.

### `auto_upgrade` (optional: boolean, default: true)
If true, disables automatic activation of `brew-upgrade.timer`.

## Development
Setting `DEBUG=true` inside `brew.sh` will enable additional output for debugging purposes during development.
