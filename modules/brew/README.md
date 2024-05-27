# brew



The brew module installs Homebrew (Brew) on your system and ensures the package manager remains updated and maintained. This module sets up systemd services to periodically update and upgrade the installed Brew packages.



## Features



- Installs Brew at build time.

- Configures and installs specified Brew packages.

- Sets up systemd services to update and upgrade Brew packages automatically.

- Options to control the frequency of updates and upgrades.



## Configuration Options



### `install_brew` (optional: boolean, default: true)



Determines whether Brew should be installed at build time. If set to `false`, Brew will not be installed.



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



### `disable_update` (optional: boolean, default: false)



If set to `true`, disables the automatic activation of the `brew-update.timer`.



### `disable_upgrade` (optional: boolean, default: false)



If set to `true`, disables the automatic activation of the `brew-upgrade.timer`.



## Example Configuration



Here is an example configuration for the Brew module in `recipe.yml`:



```yaml

---

type: brew

# Installs Brew (Homebrew) to /home/linuxbrew/.linuxbrew via external download

install_brew: true # Optional - Default: true

# List of Brew packages to be installed

packages:

  - ollama # Required

# Interval between Brew updates

update_interval: '6h'  # Optional - Default: '6h'

# Interval between Brew package upgrades

upgrade_interval: '8h' # Optional - Default: '8h'

# Time delay after boot before first Brew update

wait_after_boot_update: '10min' # Optional - Default: '10min'

# Time delay after boot before first Brew upgrade

wait_after_boot_upgrade: '30min' # Optional - Default: '30min'

# If true, disables automatic activation of `brew-update.timer`.

disable_update: false # Optional - Default: false

# If true, disables automatic activation of `brew-upgrade.timer`.

disable_upgrade: false # Optional - Default: false

```



## Development



Setting `DEBUG=true` inside `brew.sh` will enable additional output for debugging purposes during development.
