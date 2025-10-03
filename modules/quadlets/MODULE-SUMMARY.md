# Quadlets Module - Implementation Summary

## Overview

The BlueBuild quadlets module provides declarative management of Podman Quadlets with automatic updates, secrets management integration, and systemd service lifecycle management. This module brings Docker Compose-like convenience to immutable Fedora Atomic desktops while leveraging native Podman and systemd features.

## Project Goals

✅ **Declarative Configuration**: Define quadlets in `recipe.yml` just like other BlueBuild modules
✅ **Git-Based Sources**: Pull quadlets from GitHub/GitLab repositories automatically
✅ **Automatic Updates**: Keep both quadlet definitions and container images up-to-date
✅ **Secrets Integration**: Support chezmoi, Age encryption, and Podman secrets
✅ **Watchtower Replacement**: Native systemd-based container updates without extra containers
✅ **User & System Scope**: Support both user-level and system-wide deployments
✅ **CLI Management**: Comprehensive command-line tool for manual operations

## Architecture

### Build-Time (Image Creation)

```
recipe.yml
    ↓
quadlets.nu (main script)
    ↓
├─→ git-source-parser.nu (download from Git)
├─→ quadlet-validator.nu (validate syntax)
└─→ Install systemd services & CLI tool
    ↓
/usr/share/bluebuild/quadlets/
    ├── configuration.yaml
    └── [staged quadlet files]
```

### Run-Time (First Boot & Updates)

```
System Boot
    ↓
user-quadlets-setup.timer (5m delay)
    ↓
user-quadlets-setup.service
    ├─→ Copy from build-time locations
    ├─→ Discover externally-managed quadlets
    └─→ Start systemd services
    ↓
~/.config/containers/systemd/
    └── [active quadlet files]
    ↓
Periodic Updates (configurable interval)
    ↓
user-quadlets-update.service
    ├─→ Git pull latest definitions
    ├─→ Compare & update changed files
    └─→ Restart affected services
```

## Key Features

### 1. Git Repository Support

Download quadlets from any Git repository:

```yaml
- name: ai-stack
  source: https://github.com/containers/appstore/tree/main/quadlet/ai-stack
  branch: main
```

Supports:
- GitHub, GitLab, and other Git platforms
- Specific branches
- Subdirectory paths
- Sparse checkouts for efficiency

### 2. Externally-Managed Quadlets

Integrate with existing dotfile/secrets workflows:

```yaml
- name: openwebui
  source: ~/.config/containers/systemd/openwebui
  managed-externally: true
  setup-delay: 10m  # Wait for manual decryption
```

Perfect for:
- Chezmoi-managed configurations
- Age-encrypted secrets
- Manual configuration workflows

### 3. Automatic Updates

Two-tiered update system:

**Quadlet Definitions** (Module-managed):
- Periodic Git pull of quadlet files
- Configurable update interval (default: 7 days)
- Automatic service restart after updates
- Backup before updates

**Container Images** (Podman-native):
- Leverages `podman auto-update`
- Configurable schedule (daily/weekly/monthly)
- Respects `io.containers.autoupdate` labels
- No external watchtower needed

### 4. Scope Management

**User Scope** (`~/.config/containers/systemd/`):
- Runs as user
- No root required
- Starts on login
- Per-user isolation

**System Scope** (`/etc/containers/systemd/`):
- Runs as root
- System-wide services
- Starts at boot
- Shared resources

### 5. CLI Management Tool

Comprehensive CLI: `bluebuild-quadlets-manager`

```bash
# Information
show        # Show all configured quadlets
list        # List installed quadlets
status      # Service status for a quadlet
logs        # View service logs

# Operations
update      # Update from Git sources
discover    # Find externally-managed quadlets
validate    # Validate quadlet syntax

# Control
enable/disable updates  # Toggle automatic updates
```

## File Structure

```
modules/quadlets/
├── README.md                          # User documentation
├── module.yml                         # Module metadata
├── quadlets.tsp                       # TypeSpec schema
├── quadlets.nu                        # Main build script
├── INSTALLATION.md                    # Installation guide
├── TESTING.md                         # Testing guide
├── FUTURE-IMPROVEMENTS.md             # Planned features
│
├── git-source-parser.nu              # Git download logic
├── quadlet-validator.nu              # Syntax validation
│
├── post-boot/                        # Runtime scripts
│   ├── bluebuild-quadlets-manager    # CLI tool
│   ├── user-quadlets-setup           # User setup script
│   ├── user-quadlets-setup.service
│   ├── user-quadlets-setup.timer
│   ├── user-quadlets-update          # User update script
│   ├── user-quadlets-update.service
│   ├── user-quadlets-update.timer
│   ├── system-quadlets-setup         # System setup script
│   ├── system-quadlets-setup.service
│   ├── system-quadlets-update        # System update script
│   ├── system-quadlets-update.service
│   └── system-quadlets-update.timer
│
└── examples/                         # Example configurations
    ├── recipe.yml                    # Example recipe
    ├── chezmoi-integration.md        # Chezmoi guide
    ├── secrets-management.md         # Secrets guide
    ├── simple-nginx/                 # Simple example
    │   ├── README.md
    │   ├── nginx.container
    │   └── nginx.volume
    └── wordpress-pod/                # Complex example
        ├── README.md
        ├── wordpress.pod
        ├── wordpress.network
        ├── wordpress.container
        ├── wordpress-db.container
        ├── wordpress-data.volume
        └── wordpress-db-data.volume
```

## Technical Decisions

### Nushell vs Bash

**Choice**: Nushell for all scripts

**Rationale**:
- Structured data handling (YAML, JSON native)
- Better error handling
- Git operations built-in
- Consistent with `default-flatpaks` v2
- Cleaner code for complex logic

### Systemd Integration

**Choice**: Native systemd services and timers

**Rationale**:
- No additional container overhead
- Native to Fedora Atomic
- Reliable scheduling
- Integration with system management
- User & system scope support

### No Build/Runtime Separation

**Choice**: Single directory structure

**Rationale**:
- Simpler to understand
- Consistent with other modules
- Clear data flow
- Easier maintenance

### Git-First Approach

**Choice**: Git repositories as primary source

**Rationale**:
- Version control built-in
- Easy sharing and collaboration
- Branch support for testing
- Industry standard
- Future-proof

## Comparison with Alternatives

### vs Manual Quadlet Management

| Feature | Manual | This Module |
|---------|--------|-------------|
| Setup | Manual copying | Automatic |
| Updates | Manual git pull | Automatic |
| Multiple machines | Copy each time | Declared once |
| Version control | Self-managed | Built-in |
| Secrets | Self-managed | Integrated |

### vs Docker Compose

| Feature | Compose | Quadlets Module |
|---------|---------|-----------------|
| Format | docker-compose.yml | Podman Quadlet units |
| Updates | Watchtower container | Native systemd |
| Secrets | Docker secrets | Podman secrets + integration |
| Rootless | Limited | Full support |
| Systemd integration | External | Native |

### vs Watchtower

| Feature | Watchtower | This Module |
|---------|------------|-------------|
| Implementation | Container | Systemd timers |
| Resource usage | Always running | On-demand |
| Configuration | ENV vars | YAML + Quadlet labels |
| Quadlet updates | No | Yes |
| Secrets | N/A | Integrated |

## Use Cases

### 1. Personal Development Environment

```yaml
- type: quadlets
  configurations:
    - name: postgresql
      source: https://github.com/me/quadlets/tree/main/postgresql
      scope: user
    - name: redis
      source: https://github.com/me/quadlets/tree/main/redis
      scope: user
```

### 2. Home Server Services

```yaml
- type: quadlets
  configurations:
    - name: jellyfin
      source: https://github.com/me/homelab/tree/main/jellyfin
      scope: system
    - name: nextcloud
      source: https://github.com/me/homelab/tree/main/nextcloud
      scope: system
```

### 3. AI/ML Workstation

```yaml
- type: quadlets
  configurations:
    - name: ai-stack
      source: https://github.com/tulilirockz/marmorata/tree/main/quadlet/ai-stack
      scope: user
      notify: true
```

### 4. Secure Applications with Secrets

```yaml
- type: quadlets
  configurations:
    - name: openwebui
      source: ~/.config/containers/systemd/openwebui
      managed-externally: true
      setup-delay: 15m
```

## Future Roadmap

See [FUTURE-IMPROVEMENTS.md](./FUTURE-IMPROVEMENTS.md) for detailed plans.

**High Priority**:
- Staged updates with preview
- Container backup/restore
- Dependency management
- Enhanced inspection

**Medium Priority**:
- Firewall rule generation
- Multi-arch support
- Volume management tools
- Repository discovery

**Future**:
- Web UI (Cockpit plugin)
- Docker Compose migration
- Bootc integration

## Testing

Comprehensive testing framework:
- Unit tests for each component
- Integration tests for workflows
- Performance benchmarks
- Example configurations

See [TESTING.md](./TESTING.md) for details.

## Documentation

Complete documentation set:
- **README.md**: User-facing documentation
- **INSTALLATION.md**: Installation guide
- **TESTING.md**: Testing procedures
- **examples/chezmoi-integration.md**: Chezmoi workflow
- **examples/secrets-management.md**: Secrets strategies
- **FUTURE-IMPROVEMENTS.md**: Roadmap

## Acknowledgments

**Inspiration from**:
- `pq` by rgolangh - CLI patterns and quadlet management
- `marmorata/taxifolia` by tulilirockz - Justfile patterns and backup strategies
- `default-flatpaks` v2 - Nushell implementation and structure
- `brew` module - Auto-update systemd patterns

## Contributing

Areas where contributions are welcome:
1. Additional example quadlets
2. Testing on different base images
3. Documentation improvements
4. Feature implementations from roadmap
5. Bug reports and fixes

## License

Same as BlueBuild (Apache 2.0)

## Status

**Current Version**: v1.0 (Initial Release)
**Status**: Ready for testing
**Compatibility**: BlueBuild 0.8+, Fedora 40+

---

*This module brings declarative, GitOps-style container management to Fedora Atomic desktops, making complex multi-container deployments as simple as writing a few lines of YAML.*
