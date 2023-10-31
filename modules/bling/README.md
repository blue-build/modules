# [`bling`](https://github.com/ublue-os/bling) Module for Startingpoint

The `bling` module allows you to easily declare which general parts of `ublue-os/bling` to pull in to your custom image. It requires the `rpms` and `files` directories from the `bling` container to already exist inside `/tmp/bling/` (pulled inside the Containerfile by default).

The bling to pull in is declared under `install:`, and the code for installing them is all in simple named scripts under the `installers/` directory. The basic code for the `bling` module is very similar to the code of the `script` module.

## Example configuration

```yaml
type: bling # configure what to pull in from ublue-os/bling
install:
    - justfiles # add "!include /usr/share/ublue-os/just/100-bling.just"
                # in your custom.just (added by default) or local justfile
    - nix-installer # shell shortcuts for determinate system's nix installers
    - ublue-os-wallpapers
    # - ublue-update # https://github.com/ublue-os/ublue-update
    # - 1password # install 1Password (stable) and `op` CLI tool
    # - dconf-update-service # a service unit that updates the dconf db on boot
    # - devpod # https://devpod.sh/ as an rpm
    # - gnome-vrr # enables gnome-vrr for your image
    # - container-tools # installs container-related tools onto /usr/bin: kind, kubectx, docker-compose and kubens
    # - laptop # installs TLP and configures your system for laptop usage
    # - flatpaksync # allows synchronization of user-installed flatpaks, see separate documentation section
```
## Submodule documentation

### `flatpaksync`

The `flatpaksync` submodule can be used to synchronize a list of user Flatpaks with a git repository.

Once the submodule is activated, you should create the file `$HOME/.config/flatpaksync/env` that sets the `GIT_REPO`  variable to the git URL of your repository. This repository can be empty, or a previous flatpaksync installation. The repository is automatically cloned into `/tmp/sync` for the synchronization. 

```bash
# ~/.config/flatpaksync/env
GIT_REPO=<YOUR_REPO>
```

To initialize your Flatpaks from flatpaksync, simply run the `flatpakcheckout` binary to perform the installation and start the synchronization.

**It is important to note that this submodule will NOT enable Flathub. If your applications come from there, you will need to enable Flathub before running it.**

If you have configured the repository in the `$HOME/.config/flatpaksync/env` file but already have the Flatpaks installed, simply create the `$HOME/.config/flatpaks.user.installed` file to inform the script that the installation is done and start the synchronization.
