# `bling`

The `bling` module can be used to pull in small "bling" into your image. Bling is stuff that doesn't necessitate being configured at build time, in the form of configuration files or program installers.

The bling to pull in is declared under `install:`, and the code for installing them is all in simple named scripts under the `installers/` directory. The basic code for the `bling` module is very similar to the code of the `script` module.

## Submodule documentation

### `flatpaksync` (unmaintained)

The `flatpaksync` submodule can be used to synchronize a list of user Flatpaks with a git repository.

Once the submodule is activated, you should create the file `$HOME/.config/flatpaksync/env` that sets the `GIT_REPO`  variable to the git URL of your repository. This repository can be empty, or a previous flatpaksync installation. The repository is automatically cloned into `/tmp/sync` for the synchronization.

```bash
# ~/.config/flatpaksync/env
GIT_REPO=<YOUR_REPO>
```

To initialize your Flatpaks from flatpaksync, simply run the `flatpakcheckout` command to perform the installation and start the synchronization.

**It is important to note that this submodule will NOT enable Flathub. If your applications come from there, you will need to enable Flathub before running it.**

If you have configured the repository in the `$HOME/.config/flatpaksync/env` file but already have the Flatpaks installed, simply create the `$HOME/.config/flatpaks.user.installed` file to inform the script that the installation is done and start the synchronization.

### `dconf-update-service`

The `dconf-update-service` submodule will automatically update changes you make to dconf. For an example of a dconf keyfile, see the [dconf custom defaults documentation](https://help.gnome.org/admin/system-admin-guide/stable/dconf-custom-defaults.html.en).

**Unlike the `gschema-overrides` module, dconf keyfiles are not checked at compile time**
