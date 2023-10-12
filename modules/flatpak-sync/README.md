# `flatpaksync` Module for Startingpoint

The `flatpaksync` module can be used to synchronize user-installed flatpaks into a gist.

To activate it, simply follow the example below:

## Example configuration

```yaml
- type: flatpaksync
  enable: true
```

Once the module is activated, users can create a file `$HOME/.config/flatpaksync/env` informing the repository that will be used to synchronize their apps in the POSIX standard:

```bash
GIST_REPO=<YOUR_REPO>
```

If the user has not yet installed their flatpaks and has already done the step above, simply use the `flatpakcheckout` binary to perform the installation and start the synchronization.

If the user has already configured their repository in the `$HOME/.config/flatpaksync/env` file but already has their flatpaks installed, simply create the `$HOME/.config/flatpaks.user.installed` file to start the synchronization.