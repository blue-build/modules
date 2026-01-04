# **`zypper` Module**

The `zypper` module offers pseudo-declarative package and repository management using [`zypper`](https://github.com/openSUSE/zypper).

## Features

This module is capable of:

- Package Management
  - Installing packages
  - Removing packages

## Package Management

### Installing

```yaml
type: zypper
install:
  packages:
    - package-1
    - package-2
```

### Removing Packages

```yaml
type: zypper
remove:
  packages:
    - package-1
    - package-2
```
