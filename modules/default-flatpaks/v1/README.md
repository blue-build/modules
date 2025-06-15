# `default-flatpaks`

The `default-flatpaks` module can be used to install or uninstall Flatpaks from a configurable remote on every boot. It skips that operation if no changes are detected. This module, first removes the Fedora Flatpaks remote and Flatpaks that come pre-installed in Fedora (unless Fedora remote is strictly specified in recipe). A Flatpak remote is configured the first time the module is used, but it can be re-configured in subsequent usages of the module. If no Flatpak remote is specified, the module will default to using Flathub.

Flatpaks can either be installed system-wide or per-user. Per-user Flatpaks will be installed separately for every user on a system. Previously-installed flatpaks can also be removed.

The module uses the following scripts to handle flatpak setup:

- `/usr/bin/system-flatpak-setup`
- `/usr/bin/user-flatpak-setup`

The scripts are run on every boot by these services:

- `/usr/lib/systemd/system/system-flatpak-setup.service`
- `/usr/lib/systemd/user/user-flatpak-setup-service`

`system-flatpak-setup` uninstalls Fedora flatpaks, replaces Fedora repos with your repo choice, checks the Flatpak install/remove lists created by the module & performs the install/uninstall operation according to that. `user-flatpak-setup` does the same thing for user Flatpaks.

This module stores the Flatpak remote configuration and Flatpak install/remove lists in `/usr/share/bluebuild/default-flatpaks/`. There are two subdirectories, `user` and `system` corresponding with the install level of the Flatpaks and repositories. Each directory has text files containing the IDs of flatpaks to `install` and `remove`, plus a `repo-info.yml` containing the details of the Flatpak repository.

This module also supports disabling & enabling notifications. If not specified in the recipe, notifications are disabled by default.

If you wish to continue the use of Fedora flatpak remote & it's installed apps on booted system, you just need to specify the remote in the recipe (`repo-name: fedora` + `repo-url: oci+https://registry.fedoraproject.org`) & remote + all apps won't be removed (note that only `fedora` remote is supported, while `fedora-testing` isn't). When you do that, you can further customize flatpaks you want to install or remove from Fedora flatpak remote.

## Local modification

If a local user is not satisfied with default Flatpak installations and removals in the image, it is possible for them to make modifications to the default configuration through the configuration files located within this directory:

`/etc/bluebuild/default-flatpaks/`

Folder structure is the same as talked about above, with `system` & `user` folders, `install` & `remove` files containing explanation on how those should be modified & what they do. The `notifications` file also contains this explanation for turning notifications on or off.

## Known issues

Multiple repos inclusion is currently not supported (planned to implement in the future):  
https://github.com/blue-build/modules/issues/146

Flatpak runtimes are not supported due to technical difficulty in implementing those:  
https://github.com/blue-build/modules/pull/142#issuecomment-1962458757
