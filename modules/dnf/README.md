# `dnf`

The [`dnf`](https://docs.fedoraproject.org/en-US/quick-docs/dnf/) module offers pseudo-declarative package and repository management using `dnf5`.

## Package installation

- `install: packages:`
- types of packages
- `%OS_VERSION`
- flags
- from specific repos
- https://packages.fedoraproject.org/

## Package removal

- `remove: packages:` 
- flags

## Package group installation

- define
- `group-install:` `packages:`
- flags
- from specific repos(?)
- `dnf5 group list --hidden`

## Package group removal

- `group-remove: packages:` 
- flags

## Package replacement

- define
- `replace:`
- flags

## Repository management

- define
- `cleanup:`

### Adding COPR repos

- `copr:`

### Adding repo files

- `files:`
- from url and from file
- `%OS_VERSION`

### Disabling repositories

- `enable:`
- `disable:`

### Adding repo keys

- define
- `keys:`
- example

### Optfix

- define
- `optfix:`