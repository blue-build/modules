# `flatpaksync` submodule

The `flatpaksync` submodule can be used to synchronize user-installed flatpaks into a gist or traditional repository.

To activate it, simply follow the example below:

## Example configuration

```yaml
- type: bling
  # ...other submodules...
  - flatpaksync
```

Once the submodule is activated, users can create a file `$HOME/.config/flatpaksync/env` informing the repository that will be used to synchronize their apps in the POSIX standard:

```bash
GIST_REPO=<YOUR_REPO>
```

If the user has not yet installed their flatpaks, has already done the step above and has a `flatpak.list` file in the repository, simply use the `flatpakcheckout` binary to perform the installation and start the synchronization.

**It is important to note that this submodule will NOT enable Flathub. If your applications come from there, you will need to enable Flathub before running it.**

If the user has already configured their repository in the `$HOME/.config/flatpaksync/env` file but already has their flatpaks installed, simply create the `$HOME/.config/flatpaks.user.installed` file to start the synchronization.