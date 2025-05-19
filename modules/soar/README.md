# soar

The `soar` module installs & integrates [`soar`](https://github.com/pkgforge/soar) package manager, as an alternative to [Homebrew / Linuxbrew](https://brew.sh/).

[`soar`](https://github.com/pkgforge/soar) is a package manager, which manages the installation of portable & static binaries.  
[PkgForge's](https://github.com/pkgforge) `bincache` repo is used by default for the binaries.  
Other default & external repos which contain AppImages & other similar formats are removed, to make `soar` focused on CLI binaries only.  
This is configurable if you wish to have a package manager for GUI applications also in `Configuration options` section of the docs.

Those binaries are built from the GitHub's cloud registry.

Compared to [Homebrew / Linuxbrew](https://brew.sh/):  
- there are no managed dependencies for packages by design (single package = single binary).
- no conflicting system packages in the repo (like `systemd`, `dbus` or similar).
- it's simpler in design, with respect for Linux folder structuring

For more informations, please see the official documentation of [`soar`](https://github.com/pkgforge/soar):  
https://soar.qaidvoid.dev/

## Features

- Downloads & installs `soar`.
- Sets up systemd timer for auto-upgrading `soar` packages.
- Sets up shell profile for automatic directory export of `soar` packages to `PATH`.

## Local modification

By default, `soar` utilizes BlueBuild's config (`/usr/share/bluebuild/soar/config.toml`).

Local-user can have the custom `soar` config in standard or a custom directory & supply it to `soar` through aliasing it in shell profile.  
Like this (in Bash):  
```bash
soar() {
  /usr/bin/soar -c "/path/to/custom-config" "${@}"
}
export -f soar
```

Auto-upgrade `soar` timer also needs to be modified:  
- by copying the service file:
  - `sudo cp /usr/lib/systemd/system/soar-upgrade-packages.service /etc/systemd/system/soar-upgrade-packages.service`
- by copying the timer file:
  - `sudo cp /usr/lib/systemd/system/soar-upgrade-packages.timer /etc/systemd/system/soar-upgrade-packages.timer`
- by modifying the systemd service in `/etc/` to contain the custom path to the config file in `Exec`

If you specify the custom `bin_path` directory for `soar` packages & use custom config outside of `${XDG_CONFIG_HOME}/soar/config.toml`,  
you also need to export that directory manually to `PATH`.

For removing those modifications, simply revert the steps above.

## Uninstallation

Removing the `soar` module from the recipe is not enough to get it completely removed.   
On a booted system, it's also necessary to run the `soar` uninstallation script to uninstall config & installed packages in `${HOME}` directory.

Either a local-user can execute this script manually or the image-maintainer may make it automatic through a custom systemd service.

<details>
  <summary>Uninstallation script</summary>
    
```bash
#!/usr/bin/env bash

# Check if paths are defined in local config
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
if [[ -f "${config_dir}/soar/config.toml" ]]; then
  binpath="$(grep 'bin_path' "${config_dir}/soar/config.toml" | sed 's/.*=//; s/"//g; s/^[ \t]*//; s/[ \t]*$//')"
  dbpath="$(grep 'db_path' "${config_dir}/soar/config.toml" | sed 's/.*=//; s/"//g; s/^[ \t]*//; s/[ \t]*$//')"
  repospath="$(grep 'repositories_path' "${config_dir}/soar/config.toml" | sed 's/.*=//; s/"//g; s/^[ \t]*//; s/[ \t]*$//')"
  rootpath="$(grep 'root_path' "${config_dir}/soar/config.toml" | sed 's/.*=//; s/"//g; s/^[ \t]*//; s/[ \t]*$//')"
  packagespath="$(grep 'packages_path' "${config_dir}/soar/config.toml" | sed 's/.*=//; s/"//g; s/^[ \t]*//; s/[ \t]*$//')"
  if [[ -n "${binpath}" ]] && [[ -d "${binpath}" ]]; then
    echo "Removing '${binpath}' directory"
    rm -r "${binpath}"  
  fi
  if [[ -n "${dbpath}" ]] && [[ -d "${dbpath}" ]]; then
    echo "Removing '${dbpath}' directory"
    rm -r "${dbpath}"  
  fi
  if [[ -n "${repospath}" ]] && [[ -d "${repospath}" ]]; then
    echo "Removing '${repospath}' directory"
    rm -r "${repospath}"  
  fi
  if [[ -n "${rootpath}" ]] && [[ -d "${rootpath}" ]]; then
    echo "Removing '${rootpath}' directory"
    rm -r "${rootpath}"  
  fi
  if [[ -n "${packagespath}" ]] && [[ -d "${packagespath}" ]]; then
    echo "Removing '${packagespath}' directory"
    rm -r "${packagespath}"  
  fi
  echo "Removing soar config in '${config_dir}/soar/' directory"
  rm -r "${config_dir}/soar/"
fi

share_dir="${XDG_DATA_HOME:-$HOME/.local/share}"
if [[ -d "${share_dir}/soar/" ]]; then
  echo "Removing '${share_dir}/soar/' directory"
  rm -r "${share_dir}/soar/"
else
  echo "'${share_dir}/soar/' directory is already removed"
fi
```
  
</details>
