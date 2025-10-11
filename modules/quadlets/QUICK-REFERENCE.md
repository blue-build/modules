# Quadlets Module - Quick Reference

## Configuration

### Minimal
```yaml
- type: quadlets
  configurations:
    - name: my-app
      source: https://github.com/org/repo/tree/main/my-app
```

### Complete
```yaml
- type: quadlets
  configurations:
    - name: my-app
      source: https://github.com/org/repo/tree/main/my-app
      scope: user                    # user|system
      branch: main
      notify: true
      managed-externally: false
      setup-delay: 5m
  
  auto-update:
    enabled: true
    interval: 7d
    wait-after-boot: 5m
  
  container-auto-update:
    enabled: true
    interval: daily                  # daily|weekly|monthly
```

## CLI Commands

```bash
# Information
bluebuild-quadlets-manager show              # Show config
bluebuild-quadlets-manager list              # List installed
bluebuild-quadlets-manager status <name>     # Service status
bluebuild-quadlets-manager logs <name>       # View logs

# Operations
bluebuild-quadlets-manager update <name|all> # Update quadlets
bluebuild-quadlets-manager discover          # Find external quadlets
bluebuild-quadlets-manager validate <name>   # Validate syntax

# Control
bluebuild-quadlets-manager enable updates    # Enable auto-update
bluebuild-quadlets-manager disable updates   # Disable auto-update
```

## Systemctl Commands

```bash
# User Services
systemctl --user status <name>.service
systemctl --user start <name>.service
systemctl --user stop <name>.service
systemctl --user restart <name>.service
systemctl --user daemon-reload

# Timers
systemctl --user list-timers | grep quadlets
systemctl --user status user-quadlets-update.timer

# Logs
journalctl --user -u <name>.service -f
journalctl --user -u user-quadlets-setup.service
```

## File Locations

```bash
# Configuration
/usr/share/bluebuild/quadlets/configuration.yaml

# User quadlets
~/.config/containers/systemd/<name>/

# System quadlets
/etc/containers/systemd/<name>/

# Scripts
/usr/libexec/bluebuild/quadlets/

# CLI
/usr/bin/bluebuild-quadlets-manager
```

## Podman Commands

```bash
# Containers
podman ps                           # List running
podman ps -a                        # List all
podman logs <container>             # View logs
podman exec -it <container> bash    # Shell access

# Images
podman images                       # List images
podman pull <image>                 # Pull image
podman auto-update --dry-run        # Check for updates
podman auto-update                  # Update containers

# Volumes
podman volume ls                    # List volumes
podman volume inspect <volume>      # Inspect volume
podman volume export <volume>       # Backup volume
podman volume import <volume>       # Restore volume

# Pods
podman pod ps                       # List pods
podman pod inspect <pod>            # Inspect pod
podman pod start <pod>              # Start pod
podman pod stop <pod>               # Stop pod
```

## Common Tasks

### Add a New Quadlet
```yaml
# In recipe.yml
- type: quadlets
  configurations:
    - name: new-app
      source: https://github.com/org/repo/tree/main/new-app
```
Rebuild image and rebase.

### Update a Quadlet
```bash
bluebuild-quadlets-manager update new-app
```

### Check Why Service Failed
```bash
systemctl --user status app.service
journalctl --user -u app.service -n 50
podman ps -a | grep app
podman logs app-container
```

### Backup Container Data
```bash
podman volume export app-data > app-data-backup.tar
```

### Restore Container Data
```bash
podman volume import app-data < app-data-backup.tar
```

### Change Container Port
Edit `.container` file:
```ini
PublishPort=8080:80  # Change to desired port
```
Then:
```bash
systemctl --user daemon-reload
systemctl --user restart app.service
```

## Troubleshooting

### Service Won't Start
```bash
# Check quadlet syntax
podman generate systemd --files <container>

# Check systemd logs
journalctl --user -xe

# Test manually
podman run --rm -it <image> bash
```

### Updates Not Working
```bash
# Check timer
systemctl --user list-timers | grep quadlets

# Manually trigger
bluebuild-quadlets-manager update all

# Check logs
journalctl --user -u user-quadlets-update.service
```

### Git Clone Fails
```bash
# Test Git access
git clone <repo-url>

# Check network
ping github.com

# Verify URL in config
cat /usr/share/bluebuild/quadlets/configuration.yaml
```

### Port Already in Use
```bash
# Find what's using the port
ss -tlnp | grep <port>

# Change port in .container file
# Then reload and restart
```

## Quadlet File Syntax

### Container
```ini
[Unit]
Description=My App

[Container]
ContainerName=my-app
Image=docker.io/library/image:tag
PublishPort=8080:80
Volume=my-data:/data:Z
Label=io.containers.autoupdate=registry

[Service]
Restart=always

[Install]
WantedBy=default.target
```

### Pod
```ini
[Pod]
PodName=my-pod
PublishPort=8080:80
```

### Network
```ini
[Network]
NetworkName=my-network
```

### Volume
```ini
[Volume]
VolumeName=my-data
```

## Environment Variables

### In .container file
```ini
Environment=KEY=value
EnvironmentFile=%h/.config/app/.env
```

### Using Secrets
```bash
# Create secret
echo "secret-value" | podman secret create my-secret -

# Use in .container
Secret=my-secret,type=env,target=SECRET_KEY
```

## Best Practices

✅ Use `managed-externally` for secrets
✅ Enable `Label=io.containers.autoupdate=registry`
✅ Set appropriate `setup-delay` for external quadlets
✅ Use health checks in containers
✅ Backup volumes regularly
✅ Test in user scope before system scope
✅ Use descriptive quadlet names
✅ Document custom configurations

❌ Don't store secrets in Git unencrypted
❌ Don't use `scope: system` unnecessarily
❌ Don't skip health checks
❌ Don't ignore update failures
❌ Don't hardcode paths (use `%h` for home)

## Resources

- Podman Quadlet Docs: https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html
- Podman Auto-Update: https://docs.podman.io/en/latest/markdown/podman-auto-update.1.html
- Module README: See README.md
- Examples: See examples/ directory
- Testing: See TESTING.md

## Getting Help

1. Check logs: `journalctl --user -xe`
2. Validate config: `bluebuild-quadlets-manager validate <name>`
3. Test manually: `podman run --rm -it <image>`
4. Review docs: README.md, INSTALLATION.md
5. Ask community: BlueBuild Discord

---

**Quick Start**: Add to recipe.yml → Build → Rebase → Reboot → Verify with `bluebuild-quadlets-manager show`
