# **`pacman` Module**

The `pacman` module offers pseudo-declarative package and repository management using [`pacman`](https://gitlab.archlinux.org/pacman/pacman/).

## Features

This module is capable of:

- Package Management
  - Installing packages
  - Removing packages

## Package Management

### Installing

```yaml
type: pacman
install:
  packages:
    - package-1
    - package-2
```

### Removing Packages

```yaml
type: pacman
remove:
  packages:
    - package-1
    - package-2
```
