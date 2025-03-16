# **`dnf` Module**

The `dnf` module offers pseudo-declarative package and repository management using `dnf`.

## Repository Management

### Add COPR Repositories

* Specify a list of COPR repositories in the `copr` field

Example:
```yaml
type: dnf
repos:
  copr:
    - atim/starship
    - trixieua/mutter-patched
```

### Add Repository Files

* Specify a URL or file path in the `files` field to add repository files
* Use flags such as `cleanup` to customize repository management

Example:
```yaml
type: dnf
repos:
  files:
    - https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
    - custom-file.repo # file path for /files/dnf/custom-file.repo
```

### Disable/Enable Repositories

* Specify a list of repositories to disable or enable in the `disable` or `enable` field

Example:
```yaml
type: dnf
repos:
  disable:
    - repo1
    - repo2
  enable:
    - repo3
```

### Add Repository Keys

* Specify a list of repository keys in the `keys` field

Example:
```yaml
type: dnf
repos:
  keys:
    - key1
    - key2
```

## Package Installation

### Install Packages

* Specify packages to install in the `install.packages` field
* Use the `repo` parameter to specify a specific repository for installation
* Use the `%OS_VERSION%` variable to automatically determine the operating system version
* Use flags such as `skip-unavailable`, `install-weak-deps`, `skip-broken` and `allow-erasing` to customize package installation

Example:
```yaml
type: dnf
install:
  packages:
    - repo: brave-browser
      packages:
        - brave-browser
    - starship
```

### Install Packages from URL or File

* Specify a URL or file path in the `packages` field to install packages from a specific repository
* Use the `%OS_VERSION%` variable to automatically determine the operating system version

Example:
```yaml
type: dnf
install:
  packages:
    - https://github.com/Eugeny/tabby/releases/download/v1.0.209/tabby-1.0.209-linux-x64.rpm
    - custom-file.rpm # file path for /files/dnf/custom-file.rpm
```

### Install Packages from Specific Repositories

* Specify a repository in the `repo` field to install packages from that repository
* Use the `%OS_VERSION%` variable to automatically determine the operating system version

Example:
```yaml
type: dnf
install:
  packages:
    - repo: copr:copr.fedorainfracloud.org:trixieua:mutter-patched
      packages:
        - mutter
```

## Package Removal

### Remove Packages

* Specify packages to remove in the `remove.packages` field
* Use flags such as `auto-remove` to customize package removal

Example:
```yaml
type: dnf
remove:
  packages:
    - firefox
    - firefox-langpacks
```

## Package Group Installation

### Define Packages Groups

* Specify a package group in the `group-install.packages` field
* Use flags such as `skip-unavailable`, `install-weak-deps`, `skip-broken` and `allow-erasing` to customize package installation

Example:
```yaml
type: dnf
group-install:
  packages:
    - cosmic-desktop
    - window-managers
```

## Package Group Removal

### Remove Packages Groups

* Specify a package group in the `group-remove.packages` field

Example:
```yaml
type: dnf
group-remove:
  packages:
    - development-tools
```

## Package Replacement

### Replace Packages

* Specify a replacement package in the `replace.from-repo` field
* If new package for replacement is named differently, you can use `old/new` format as outlined below
* Use flags such as `skip-unavailable`, `install-weak-deps`, `skip-broken` and `allow-erasing` to customize package installation

Example:
```yaml
type: dnf
replace:
  - from-repo: copr:copr.fedorainfracloud.org:trixieua:mutter-patched
    packages:
      - mutter
  - from-repo: fedora
    packages:
      - old: OpenCL-ICD-Loader
        new: ocl-icd
```

## Optfix

### Fix Optfix

* Specify a list of packages to fix optfix issues in the `optfix` field

Example:
```yaml
type: dnf
optfix:
  packages:
    - package1
    - package2
```

## Known issues

Replacing the kernel with `dnf` module is not done cleanly & some remaints of old kernel will be present.  
Please use `rpm-ostree` module for this purpose until this `dnf` behavior is fixed.
