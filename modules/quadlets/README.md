# `quadlets`

The quadlets module manages Podman Quadlet deployments on your system. Quadlets are systemd unit files that define containers, pods, networks, and volumes, providing a declarative way to manage containerized applications.

## Features

- Install quadlets from Git repositories (GitHub, GitLab, etc.)
- Support for locally-managed quadlets (chezmoi, manual editing)
- Automatic updates from Git sources
- Container image auto-updates via Podman's built-in features
- Per-quadlet systemd service management
- Desktop notifications for operations
- CLI tool for manual management

## How It Works

### Build-Time

The module downloads quadlets from specified Git sources and prepares them for installation:

1. Clones Git repositories and extracts quadlet directories
2. Validates quadlet file syntax and structure
3. Generates configuration file at `/usr/share/bluebuild/quadlets/configuration.yaml`
4. Sets up systemd services and timers for auto-updates
5. Enables Podman's auto-update feature for container images

### Run-Time

On first boot and periodically thereafter:

1. **Initial Setup**: Copies quadlets from build-time locations to runtime directories
   - User scope: `~/.config/containers/systemd/`
   - System scope: `/etc/containers/systemd/`
2. **Discovery**: Finds externally-managed quadlets (e.g., from chezmoi)
3. **Systemd Integration**: Reloads daemon and starts quadlet services
4. **Auto-Updates**: Periodically checks Git sources for updates and pulls new container images

## Quick Start

### 1. Add to Your Recipe

```yaml
modules:
  - type: quadlets
    configurations:
      - name: ai-stack
        source: https://github.com/rgolangh/podman-quadlets/tree/main/ai-stack
        scope: user
        notify: true
```

### 2. Build Your Image

```bash
bluebuild build -r recipe.yml
```

### 3. Install/Rebase

```bash
# For Silverblue/Kinoite
rpm-ostree rebase ostree-unverified-registry:ghcr.io/username/image:latest
systemctl reboot
```

### 4. Verify Installation

After reboot:

```bash
# Check configuration
bluebuild-quadlets-manager show

# List installed quadlets
bluebuild-quadlets-manager list

# Check service status
systemctl --user status ai-stack.service
```

## Configuration

### Basic Example

```yaml
type: quadlets
configurations:
  - name: ai-stack
    source: https://github.com/rgolangh/podman-quadlets/tree/main/ai-stack
    scope: user
    notify: true
```

### Git Source with Branch

```yaml
type: quadlets
configurations:
  - name: nextcloud
    source: https://github.com/rgolangh/podman-quadlets/tree/dev/nextcloud
    scope: user
    branch: dev
```

### Externally-Managed (Chezmoi/Secrets)

```yaml
type: quadlets
configurations:
  - name: openwebui
    source: ~/.config/containers/systemd/openwebui
    scope: user
    managed-externally: true
    setup-delay: 10m  # Wait for manual secret decryption
```

### Multiple Quadlets

```yaml
type: quadlets
configurations:
  - name: ai-stack
    source: https://github.com/rgolangh/podman-quadlets/tree/main/ai-stack
    scope: user
    
  - name: wordpress
    source: https://github.com/rgolangh/podman-quadlets/tree/main/wordpress
    scope: user
    notify: false
    
  - name: monitoring
    source: https://github.com/org/repo/tree/main/monitoring
    scope: system  # System-wide installation
```

### Full Configuration Options

```yaml
type: quadlets

configurations:
  - name: my-app
    source: https://github.com/org/repo/tree/branch/path
    scope: user              # "user" or "system" (default: user)
    branch: main             # Git branch (default: main)
    notify: true             # Desktop notifications (default: true)
    managed-externally: false # Don't copy, only discover (default: false)
    setup-delay: 5m          # Delay before discovery (default: 5m)

# Quadlet definition updates
auto-update:
  enabled: true              # Enable auto-updates (default: true)
  interval: 7d               # Update check interval (default: 7d)
  wait-after-boot: 5m        # Delay after boot (default: 5m)

# Container image updates (Podman auto-update)
container-auto-update:
  enabled: true              # Enable container updates (default: true)
  interval: daily            # Update interval: daily, weekly, monthly (default: daily)
```

## Scope: User vs System

### User Scope (`scope: user`)
- Installs to `~/.config/containers/systemd/`
- Runs as the user
- Services start on user login
- No root privileges required for management
- Ideal for personal services and development

### System Scope (`scope: system`)
- Installs to `/etc/containers/systemd/`
- Runs as root
- Services start at system boot
- Requires root for management
- Ideal for system-wide services and multi-user setups

## CLI Management

The module installs `bluebuild-quadlets-manager` for manual management:

```bash
# Show all configured quadlets
bluebuild-quadlets-manager show

# List installed quadlets
bluebuild-quadlets-manager list

# Update specific quadlet
bluebuild-quadlets-manager update ai-stack

# Update all quadlets
bluebuild-quadlets-manager update all

# Check service status
bluebuild-quadlets-manager status ai-stack

# View logs
bluebuild-quadlets-manager logs ai-stack

# Discover externally-managed quadlets
bluebuild-quadlets-manager discover

# Enable/disable auto-updates
bluebuild-quadlets-manager disable updates
bluebuild-quadlets-manager enable updates
```

## Container Auto-Updates

The module enables Podman's built-in auto-update feature, which updates container images based on labels:

```ini
# In your .container file
[Container]
Image=ghcr.io/owner/image:latest
Label=io.containers.autoupdate=registry
```

Supported update policies:
- `registry` - Check registry for newer images
- `local` - Only update from local builds
- Omit label to disable auto-updates for this container

## Watchtower Replacement

This module replaces Watchtower by combining:
1. **Quadlet Updates**: Periodic checks for updated quadlet definitions from Git
2. **Container Updates**: Podman's native `podman auto-update` feature
3. **Systemd Integration**: Native systemd timers instead of a separate container

Benefits over Watchtower:
- No separate container required
- Native systemd integration
- Respects quadlet labels and policies
- Better rollback support through systemd
- Lower resource usage

## Integration with Secrets Management

For quadlets that require secrets (API keys, passwords, etc.), see the [Secrets Management Guide](./examples/secrets-management.md) and [Chezmoi Integration Guide](./examples/chezmoi-integration.md).

The `managed-externally` flag allows you to:
1. Manage quadlet files with your secrets workflow (chezmoi, ansible, etc.)
2. Have the module discover and manage the systemd integration
3. Still receive updates if you specify a Git source for reference

## Directory Structure

After installation:

```
# Build-time locations
/usr/share/bluebuild/quadlets/
├── configuration.yaml              # Module configuration
└── user/                           # Staged user quadlets
    └── app-name/
        ├── app.container
        └── app.volume

/usr/libexec/bluebuild/quadlets/
├── user-quadlets-setup             # Setup scripts
├── user-quadlets-update
├── system-quadlets-setup
└── system-quadlets-update

# Runtime locations (user scope)
~/.config/containers/systemd/
└── app-name/
    ├── app.container
    └── app.volume

# Runtime locations (system scope)
/etc/containers/systemd/
└── app-name/
    ├── app.container
    └── app.volume
```

## Troubleshooting

### Quadlets not starting

```bash
# Check systemd status
systemctl --user status quadlet-name.service

# View logs
journalctl --user -u quadlet-name.service

# Validate quadlet syntax
bluebuild-quadlets-manager validate quadlet-name
```

### Updates not working

```bash
# Check timer status
systemctl --user status user-quadlets-update.timer

# Manually trigger update
bluebuild-quadlets-manager update all

# Check update logs
journalctl --user -u user-quadlets-update.service
```

### Secrets not working

If using `managed-externally`, ensure:
1. Your secrets workflow runs before the setup timer
2. The `setup-delay` is long enough for manual steps
3. Files are in the correct location for the specified scope

### Build Failures

```bash
# Verbose build
bluebuild build -r recipe.yml --verbose

# Check recipe syntax
yq eval recipe.yml

# Validate configuration
bluebuild validate recipe.yml
```

### Services Not Starting

```bash
# Reload systemd
systemctl --user daemon-reload

# Check service file
systemctl --user cat app-name.service

# Check errors
systemctl --user status app-name.service

# Manual start
systemctl --user start app-name.service
```

### Git Download Failures

```bash
# Test Git access
git clone https://github.com/org/repo

# Check network
ping github.com

# Verify URL in configuration
cat /usr/share/bluebuild/quadlets/configuration.yaml
```

## Verification

### Check Module is Active

```bash
# Configuration exists
cat /usr/share/bluebuild/quadlets/configuration.yaml

# CLI available
which bluebuild-quadlets-manager

# Timers enabled
systemctl --user list-timers | grep quadlets
```

### Check Quadlets Installed

```bash
# User quadlets
ls ~/.config/containers/systemd/

# System quadlets
ls /etc/containers/systemd/

# Services
systemctl --user list-units | grep -E '\.container|\.service'
```

### Check Services Running

```bash
# Status
bluebuild-quadlets-manager status app-name

# Or directly with systemctl
systemctl --user status app-name.service

# Logs
journalctl --user -u app-name.service -f
```

## Examples

See the [examples](./examples/) directory for:
- Simple nginx server example
- Multi-container WordPress setup
- Chezmoi integration patterns
- Secrets management strategies

## Uninstallation

To remove the quadlets module:

### 1. Remove from Recipe

Remove or comment out the quadlets module in your `recipe.yml`:

```yaml
# modules:
#   - type: quadlets
#     ...
```

### 2. Rebuild and Rebase

```bash
bluebuild build -r recipe.yml
rpm-ostree rebase ostree-unverified-registry:ghcr.io/username/new-image:latest
systemctl reboot
```

### 3. Clean Up (Optional)

After reboot, remove leftover files:

```bash
# Stop services
systemctl --user stop *.service

# Remove quadlets
rm -rf ~/.config/containers/systemd/

# Remove volumes (careful! This deletes data)
podman volume ls
podman volume rm volume-name

# Remove images
podman image ls
podman image rm image-name
```

## Resources

- [Podman Quadlet Documentation](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html)
- [Podman Auto-Update](https://docs.podman.io/en/latest/markdown/podman-auto-update.1.html)
- [Quadlet Examples Repository](https://github.com/rgolangh/podman-quadlets)
- [Chezmoi Integration Guide](./examples/chezmoi-integration.md)
- [Secrets Management Guide](./examples/secrets-management.md)
- [Testing Guide](./TESTING.md)
- [Quick Reference](./QUICK-REFERENCE.md)

## Getting Help

- **Examples**: Check [examples/](./examples/) directory
- **Testing**: See [TESTING.md](./TESTING.md) to verify installation
- **Issues**: Report bugs on GitHub
- **Community**: Ask questions on BlueBuild Discord
