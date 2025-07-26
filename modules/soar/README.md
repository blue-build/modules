# soar

The `soar` module installs & integrates the [`soar`](https://github.com/pkgforge/soar) package manager as an alternative to [Homebrew / Linuxbrew](https://brew.sh/).

[`soar`](https://github.com/pkgforge/soar) is a package manager, which manages the installation of portable & static binaries.
[PkgForge's](https://github.com/pkgforge) `bincache`, `pkgforge-cargo` & `pkgforge-go` repos are used by default for the binaries.
Other default & external repos that contain AppImages & other similar formats are disabled to make `soar` focused on CLI binaries only.
This is configurable if you wish to have a package manager for GUI applications, see [`Configuration options`](#configuration-options).

The repositories with prebuilt binaries use the GitHub Container registry as their backend and all their packages are published there.

Compared to [Homebrew / Linuxbrew](https://brew.sh/):
- there are no managed dependencies for packages by design (single package = single binary).
- no conflicting system packages in the repo (like `systemd`, `dbus` or similar).
- it's simpler in design, with respect for Linux folder structuring

For more information, please see the [official documentation of `soar`](https://soar.qaidvoid.dev/).

## Features

- Downloads & installs `soar`.
- Sets up systemd timer for auto-upgrading `soar` packages.
- Sets up shell profile for automatically adding the directory containing `soar` binaries to `PATH`.

## Repos

To see the useful information about source, reliability, trust & security of all `soar` repos, including external ones, you can open the links below:
- https://docs.pkgforge.dev/repositories
- https://docs.pkgforge.dev/repositories/external

## Local modification

By default, `soar` utilizes BlueBuild's config (`/usr/share/bluebuild/soar/config.toml`).

End-users can use custom a `soar` configuration by creating it at `~/.config/soar/config.toml`, or in a custom directory while making sure to supply it to `soar` by providing `SOAR_CONFIG` the environment variable in shell profile.
If you specify the custom `bin_path` directory for `soar` packages, you also need to export that directory to `PATH` manually in the shell profile.

## Uninstallation

Removing the `soar` module from the recipe is not enough to get it completely removed.
On a booted system, it's also necessary to run the `soar` uninstallation script to uninstall config & installed packages in the `${HOME}` directory.

Either a local-user can execute this script manually, or the image-maintainer may make it automatic through a custom systemd service.

<details>
  <summary>Uninstallation script</summary>

```sh
#!/bin/sh
if [ -f "${XDG_CONFIG_HOME:-$HOME/.config}/soar/config.toml" ]; then
  echo "Removing soar config in '${XDG_CONFIG_HOME:-$HOME/.config}/soar/' directory"
  rm -r "${XDG_CONFIG_HOME:-$HOME/.config}/soar/"
else
  echo "'${XDG_CONFIG_HOME:-$HOME/.config}/soar/config.toml' file is already removed"
fi
if [ -d "${XDG_DATA_HOME:-$HOME/.local/share}/soar/" ]; then
  echo "Removing '${XDG_DATA_HOME:-$HOME/.local/share}/soar/' directory"
  rm -r "${XDG_DATA_HOME:-$HOME/.local/share}/soar/"
else
  echo "'${XDG_DATA_HOME:-$HOME/.local/share}/soar/' directory is already removed"
fi
```

</details>
