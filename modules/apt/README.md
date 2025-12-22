# **`apt` Module**

The `apt` module offers pseudo-declarative package and repository management using [`apt`](https://salsa.debian.org/apt-team/apt).

## Features

This module is capable of:

- Package Management
  - Installing packages
  - Removing packages

## Package Management

### Installing

```yaml
type: apt
install:
  packages:
    - package-1
    - package-2
```

### Removing Packages

```yaml
type: apt
remove:
  packages:
    - package-1
    - package-2
```
