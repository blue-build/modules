# **`apk` Module**

The `apk` module offers pseudo-declarative package and repository management using [`apk`](https://github.com/alpinelinux/apk-tools).

## Features

This module is capable of:

- Package Management
  - Installing packages
  - Removing packages

## Package Management

### Installing

```yaml
type: apk
install:
  packages:
    - package-1
    - package-2
```

### Removing Packages

```yaml
type: apk
remove:
  packages:
    - package-1
    - package-2
```
