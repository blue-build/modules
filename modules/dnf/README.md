# **`dnf` Module**

The `dnf` module offers pseudo-declarative package and repository management using [`dnf5`](https://github.com/rpm-software-management/dnf).

## Features

This module is capable of:

- Repository Management
  - Enabling/disabling COPR repos
  - Adding repo files via url or local files
  - Removing repos by specifying the repo name
  - Automatically cleaning up any repos added in the module
  - Adding keys for repos via url or local files
  - Adding non-free repos like `rpmfusion` and `negativo17`
- Package Management
  - Installing packages from RPM urls, local RPM files, or package repositories
  - Installing packages from a specific repository
  - Removing packages
  - Replacing installed packages with versions from another repository
- Optfix
  - Setup symlinks to `/opt/` to allow certain packages to install

## Repository Management

### Add Repository Files

- Add repos from
  - any `https://` or `http://` URL
  - any `.repo` files located in `./files/dnf/` of your image repo
- If the OS version is included in the file name or URL, you can substitute it with the `%OS_VERSION%` magic string
  - The version is gathered from the `VERSION_ID` field of `/usr/lib/os-release`

```yaml
type: dnf
repos:
  files:
    - https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
    - custom-file.repo # file path for /files/dnf/custom-file.repo
```

### Add COPR Repositories

- [COPR](https://copr.fedorainfracloud.org/) contains software repositories maintained by fellow Fedora users

```yaml
type: dnf
repos:
  copr:
    - atim/starship
    - trixieua/mutter-patched
```

### Disable/Enable Repositories
```yaml
type: dnf
repos:
  files:
    add:
      - repo1
      - repo2
    remove:
      - repo3
  copr:
    enable:
      - ryanabx/cosmic-epoch
    disable:
      - kylegospo/oversteer
```

### Add Repository Keys
```yaml
type: dnf
repos:
  keys:
    - https://example.com/repo-1.asc
    - key2.asc
```

## Package Management

### Packages from Any Repository
```yaml
type: dnf
install:
  packages:
    - package-1
    - package-2
```

### Packages from URL or File

- If the OS version is included in the file name or URL, you can substitute it with the `%OS_VERSION%` magic string
  - The version is gathered from the `VERSION_ID` field of `/usr/lib/os-release`

```yaml
type: dnf
install:
  packages:
    - https://example.com/package-%OS_VERSION%.rpm
    - custom-file.rpm # install files/dnf/custom-file.rpm from the image repository
```

### Install Packages from Specific Repositories

- Set `repo` to the name of the RPM repository, not the name or URL of the repo file

```yaml
type: dnf
install:
  packages:
    - repo: copr:copr.fedorainfracloud.org:custom-user:custom-repo
      packages:
        - package-1
```

### Remove Packages
```yaml
type: dnf
remove:
  packages:
    - package-1
    - package-2
```

### Install Package Groups

- See list of all package groups by running `dnf5 group list --hidden` on a live system

```yaml
type: dnf
group-install:
  packages:
    - de-package-1
    - wm-package-2
```

### Remove Package Groups
```yaml
type: dnf
group-remove:
  packages:
    - de-package-2
```

### Replace Packages
```yaml
type: dnf
replace:
  - from-repo: copr:copr.fedorainfracloud.org:custom-user:custom-repo
    packages:
      - package-1
  - from-repo: repo-1
    packages:
      - old: old-package-2
        new: new-package-2
```

## Optfix

- Optfix is a script used to work around problems with certain packages that install into `/opt/`
  - These issues are caused by Fedora Atomic storing `/opt/` at the location `/var/opt/` by default, while `/var/` is only writeable on a live system
  - The script works around these issues by moving the folder to `/usr/lib/opt/` and creating the proper symlinks at runtime
- Specify a list of folders inside `/opt/`

```yaml
type: dnf
optfix:
  - brave.com
  - foldername
```

## Known issues

Replacing the kernel with the `dnf` module is not done cleanly at the moment & some remaints of old kernel will be present.  
Please use the `rpm-ostree` module for this purpose until this `dnf` behavior is fixed.

## Note

This documentation page uses the installation of the Brave Browser as an example of a package that required a custom repository, with a custom key, and an optfix configuration to install properly. This is not an official endorsement of the Brave Browser by the BlueBuild project.
