# [`bling`](https://github.com/ublue-os/bling) Module for Startingpoint

The `bling` module allows you to easily declare which general parts of `ublue-os/bling` to pull in to your custom image. It requires the `rpms` and `files` directories from the `bling` container to already exist inside `/tmp/bling/` (pulled inside the Containerfile by default).

The bling to pull in is declared under `install:`, and the code for installing them is all in simple named scripts under the `installers/` directory. The basic code for the `bling` module is very similar to the code of the `script` module.

## Example configuration

```yaml
type: bling # configure what to pull in from ublue-os/bling
install:
    - justfiles # add "!include /usr/share/ublue-os/just/100-bling.just"
                # in your custom.just (added by default) or local justfile
    - nix-installer # these are the silverblue nix installer scripts from dnkmmr69420
    - ublue-os-wallpapers
    # - ublue-update # https://github.com/ublue-os/ublue-update
    # - dconf-update-service # a service unit that updates the dconf db on boot
    # - devpod # https://devpod.sh/ as an rpm
    # - gnome-vrr # enables gnome-vrr for your image 
    # - container-tools # installs container-related tools onto /usr/bin: kind, kubectx, docker-compose and kubens 
    # - laptop # installs TLP and configures your system for laptop usage
    # - flatpaksync # allows synchronization of user-installed flatpaks, see separate documentation section
```
## Submodule documentation

### `flatpaksync`

The `flatpaksync` submodule can be used to synchronize user-installed flatpaks into a gist or traditional repository.

Once the submodule is activated, users can create a file `$HOME/.config/flatpaksync/env` informing the repository that will be used to synchronize their apps in the POSIX standard:

```bash
GIT_REPO=<YOUR_REPO>
```

If the user has not yet installed their flatpaks, has already done the step above and has a `flatpak.list` file in the repository, simply use the `flatpakcheckout` binary to perform the installation and start the synchronization.

**It is important to note that this submodule will NOT enable Flathub. If your applications come from there, you will need to enable Flathub before running it.**

If the user has already configured their repository in the `$HOME/.config/flatpaksync/env` file but already has their flatpaks installed, simply create the `$HOME/.config/flatpaks.user.installed` file to start the synchronization.
