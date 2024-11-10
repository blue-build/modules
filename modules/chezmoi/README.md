# `chezmoi`

The `chezmoi` module takes care of installing, initializing and updating your dotfiles.
Each feature can be enabled or disabled individually.

Installation of the `chezmoi` binary happens at build time and is done by downloading the `amd64` binary from the latest release to `/usr/bin/chezmoi`.
This can be disabled by setting `install` to false. (defaults: true)

Choose how `chezmoi` handles conflicting files with `file-conflict-policy`.
The following values are valid:
`"skip"` Will not take any action if the file has changed from what is in your dotfiles repository.
This executes `chezmoi update --no-tty --keep-going` under the hood.
`"replace"` Will overwrite the file if it has changed from what is in your dotfiles repository.
This executes `chezmoi update --no-tty --force` under the hood.

See `chezmoi`s documentation for [`--no-tty`](https://www.chezmoi.io/reference/command-line-flags/global/#-no-tty), [`--keep-going`](https://www.chezmoi.io/reference/command-line-flags/global/#-k-keep-going) and [`--force`](https://www.chezmoi.io/reference/command-line-flags/global/#-force) for details.

A systemd user service is installed that will initialize a `chezmoi` repository on chezmoi's default path (`~/.local/share/chezmoi`) for any user when it logs in, or at boot if it has lingering enabled.
The service will only run if `~/.local/share/chezmoi` does not exist.
Set `repository` to the URL of your dotfiles repository. (eg. `repository: https://example.org/user/dotfiles`). You can also set `branch` if you want to use a branch different than the default.
:::note
The value of `repository` and `branch` will be passed directly to `chezmoi init --apply ${repository} --branch ${branch}`.
See the [`chezmoi init` documentation](https://www.chezmoi.io/reference/commands/init/) for detailed syntax.
:::
Set `disable-init` to `true` if you do not want to install the init service.

:::caution
If `repository` is not set, and `disable-init` is false the module will fail, due to not being able to initialize the repository.
:::

Set `all-users` to `false` if you want to install the update and initialization services, but do not want them enabled for all users.
You can enable them manually instead when the system has been installed:

To enable the services for a single user, run the following command as that user:

```bash
systemctl enable --user chezmoi-init.service chezmoi-update.timer
```

To manually enable the services for all users, run the following command with sudo:

```bash
sudo systemctl enable --user chesmoi-init.service chezmoi-update.timer
```

To turn on lingering for a given user, run the following command with sudo:

:::note
By default, any systemd units in a user's namespace will run after the user logs in, and will close after the user closes their last session.
When you enable lingering for a user, that user's units will run at boot and will continue running even if the user has no active sessions.

If your dotfiles only contain things used by humans, such as cosmetic settings and aliases, you shouldn't need this.
If you understand the above implications, and decide you need this feature, you can enable it with the following command, after installation:
:::

```bash
sudo loginctl enable-linger <username>`
```

You can configure the interval between updates of your dotfiles by setting the value of `run-every`.
The string is passed directly to OnUnitInactiveSec. (default: '1d')
See [`systemd.time` documentation](https://www.freedesktop.org/software/systemd/man/latest/systemd.time.html) for detailed syntax.
Examples: '1d' (1 day - default), '6h' (6 hours), '10m' (10 minutes)

Likewise, `wait-after-boot` configures the delay between the system booting and the update service starting.
This follows the same syntax as `run-every`. (default: '5m')

The installation of the initialization service and the update service can be disabled separately by setting `disable-init` and/or `disable-update` to `true`. (Both default: false)

:::caution
Note that this will skip the installation of the services completely. If you want them installed but disabled, see `all-users` instead.
:::

## Development

Setting `DEBUG=true` inside `chezmoi.sh` will enable additional output in bash useful for debugging.
