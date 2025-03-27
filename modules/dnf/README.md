# **`dnf` Module**

The `dnf` module offers pseudo-declarative package and repository management using [`dnf5`](https://github.com/rpm-software-management/dnf).

## Features

This module is capable of:

- Repository Management
  - Adding repo files via url or local files
  - Removing repos by specifying the repo name
  - Automatically cleaning up any repos added in the module
  - Adding keys for repos via url or local files
  - Enabling/disabling COPR repos
  - Adding non-free repos like `rpmfusion` and `negativo17`
- Package Management
  - Installing packages via url, local rpm files, or repo packaging
  - Specifying repos from which to install packages
  - Removing packages
  - Replacing packages with ones from another repo
- Optfix
  - Setup symlinks to `/opt/` to allow certain packages to install

### Add Repository Files

- Add repos from any `https://` or `http://` URL
- Any `.repo` files located in `./files/dnf/` of your image repo

```yaml
type: dnf
repos:
  files:
    - https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
    - custom-file.repo # file path for /files/dnf/custom-file.repo
```

### Add COPR Repositories
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

### Packages
```yaml
type: dnf
install:
  packages:
    - repo: repo-1
      packages:
        - repo-1-package-1
        - repo-1-package-2
    - package-3
```

### Packages from URL or File
```yaml
type: dnf
install:
  packages:
    - https://example.com/package-%OS_VERSION%.rpm
    - custom-file.rpm # file path for /files/dnf/custom-file.rpm
```

### Install Packages from Specific Repositories
```yaml
type: dnf
install:
  packages:
    - repo: copr:copr.fedorainfracloud.org:custom-user:custom-repo
      packages:
        - package1
```

### Remove Packages
```yaml
type: dnf
remove:
  packages:
    - package1
    - package-2
```

### Define Packages Groups
```yaml
type: dnf
group-install:
  packages:
    - de-package-1
    - wm-package-2
```

### Remove Packages Groups
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

### Optfix
- Optfix is a script used to work around problems with certain packages that install into `/opt/`
  - These issues are caused by Fedora Atomic storing `/opt/` at the location `/var/opt/` by default, while `/var/` is only writeable on a live system
  - The script works around these issues by moving the folder to `/usr/lib/opt/` and creating the proper symlinks at runtime
- Specify a list of folders inside `/opt/`

```yaml
type: dnf
optfix:
  - package1
  - package2
```

## Known issues

Replacing the kernel with `dnf` module is not done cleanly & some remaints of old kernel will be present.  
Please use `rpm-ostree` module for this purpose until this `dnf` behavior is fixed.
