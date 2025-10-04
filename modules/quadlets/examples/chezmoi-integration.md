# Integrating Quadlets with Chezmoi

## Overview

If you manage your dotfiles with chezmoi and need to handle secrets (API keys, passwords, etc.), you can have chezmoi manage your quadlet files while letting the quadlets module handle systemd integration and service management.

## Why This Approach?

- **Secrets Management**: Keep sensitive data encrypted in your dotfiles repo
- **Templating**: Use chezmoi templates for dynamic configuration
- **Version Control**: Track changes to your quadlet configurations
- **Portability**: Apply the same setup across multiple machines

## Setup

### 1. Configure Quadlets Module

In your BlueBuild `recipe.yml`:

```yaml
type: quadlets
configurations:
  - name: openwebui
    source: ~/.config/containers/systemd/openwebui
    scope: user
    managed-externally: true
    setup-delay: 10m  # Give yourself time to decrypt
    notify: true
```

Key points:
- `managed-externally: true` - Module won't copy files, only discover them
- `setup-delay: 10m` - Wait this long after boot before looking for the quadlet
- `source` - Where chezmoi will place the files

### 2. Structure in Chezmoi

Organize your quadlets in chezmoi's directory structure:

```
~/.local/share/chezmoi/
└── private_dot_config/
    └── containers/
        └── systemd/
            └── openwebui/
                ├── open-webui.container.tmpl
                ├── ollama.container.tmpl
                ├── openwebui.pod
                ├── openwebui.network
                ├── open-webui.service.d/
                │   └── encrypted_env.age  # Encrypted secrets
                └── README.md
```

### 3. Template Example

Create a `.tmpl` file for containers that need configuration:

**`open-webui.container.tmpl`**:
```ini
[Unit]
Description=Open WebUI Container
After=ollama.service

[Container]
ContainerName=open-webui
Image=ghcr.io/open-webui/open-webui:latest
Pod=openwebui

# Environment from decrypted file
EnvironmentFile=%h/.config/containers/systemd/openwebui/open-webui.service.d/env

Label=io.containers.autoupdate=registry

[Install]
WantedBy=default.target
```

### 4. Encrypt Secrets with Age

Encrypt sensitive environment files:

```bash
# Create your env file
cat > env << EOF
OPENAI_API_KEY=sk-...
OLLAMA_API_KEY=...
DATABASE_PASSWORD=...
EOF

# Encrypt it with your Age key
chezmoi encrypt env

# Add to chezmoi
chezmoi add --encrypt ~/.config/containers/systemd/openwebui/open-webui.service.d/env
```

### 5. First Boot Workflow

After building and installing your image:

1. **Boot the system**
   - System starts, quadlets module waits (10m delay)

2. **Plug in USB with Age key**
   - Insert your USB drive containing the Age private key

3. **Initialize chezmoi with decryption**
   ```bash
   # Set Age key path
   export CHEZMOI_AGE_KEY_FILE=/path/to/usb/key.txt
   
   # Initialize and apply
   chezmoi init --apply https://github.com/yourusername/dotfiles.git
   ```

4. **Verify quadlets are in place**
   ```bash
   ls ~/.config/containers/systemd/openwebui/
   # Should show: open-webui.container, ollama.container, etc.
   ```

5. **Trigger discovery (or wait for timer)**
   ```bash
   # Manual trigger
   bluebuild-quadlets-manager discover
   
   # Or wait for the setup timer to run
   ```

6. **Check status**
   ```bash
   bluebuild-quadlets-manager status openwebui
   systemctl --user status open-webui.service
   ```

## Advanced: Auto-Update Templates

Have chezmoi update your quadlets automatically:

**`.chezmoiignore`** (for files you don't want to track):
```
openwebui/open-webui.service.d/env
```

**`run_after_apply.sh.tmpl`** (post-apply script):
```bash
#!/bin/bash
# After chezmoi applies changes, reload quadlets

if systemctl --user is-active openwebui.service >/dev/null 2>&1; then
    echo "Reloading Open WebUI quadlet..."
    systemctl --user daemon-reload
    systemctl --user restart openwebui.service
fi
```

## Tips

### Multiple Environments

Use chezmoi templates to handle different environments:

**`.chezmoi.toml.tmpl`**:
```toml
{{- $env := promptString "environment" "dev" -}}

[data]
    environment = {{ $env | quote }}
```

**`open-webui.container.tmpl`**:
```ini
[Container]
{{- if eq .environment "prod" }}
Image=ghcr.io/open-webui/open-webui:latest
{{- else }}
Image=ghcr.io/open-webui/open-webui:dev
{{- end }}
```

### Conditional Quadlets

Enable/disable quadlets based on machine:

**`.chezmoi.toml.tmpl`**:
```toml
{{- $features := list "ai" "monitoring" -}}
{{- $features := promptStringSlice "features" $features -}}

[data]
    features = {{ $features | toJson }}
```

**`openwebui.container.tmpl`** (only apply if "ai" feature enabled):
```yaml
{{- if has "ai" .features }}
[Container]
# ... container definition
{{- end }}
```

### Backup Before Updates

Create a chezmoi script to backup before updating:

**`run_before_apply.sh`**:
```bash
#!/bin/bash
# Backup current quadlet state before updating

BACKUP_DIR="$HOME/.local/share/quadlets-backup"
QUADLET_DIR="$HOME/.config/containers/systemd"

mkdir -p "$BACKUP_DIR"
timestamp=$(date +%Y%m%d-%H%M%S)

if [ -d "$QUADLET_DIR/openwebui" ]; then
    tar czf "$BACKUP_DIR/openwebui-$timestamp.tar.gz" \
        -C "$QUADLET_DIR" openwebui
    echo "Backed up to: $BACKUP_DIR/openwebui-$timestamp.tar.gz"
fi
```

## Troubleshooting

### Quadlets not appearing

```bash
# Check chezmoi applied correctly
chezmoi verify

# Check target directory
ls -la ~/.config/containers/systemd/openwebui/

# Check setup service status
systemctl --user status user-quadlets-setup.service
```

### Secrets not decrypting

```bash
# Verify Age key is accessible
age -d -i /path/to/key.txt < encrypted_file

# Check chezmoi encryption
chezmoi verify

# Re-apply with verbose output
chezmoi apply -v
```

### Services not starting

```bash
# Check systemd status
systemctl --user status openwebui.service

# View logs
journalctl --user -u openwebui.service

# Verify environment file exists and is readable
cat ~/.config/containers/systemd/openwebui/open-webui.service.d/env
```

## Example Repository Structure

Complete example of a chezmoi repository with quadlets:

```
dotfiles/
├── .chezmoi.toml.tmpl
├── .chezmoiignore
│
├── private_dot_config/
│   └── containers/
│       └── systemd/
│           ├── openwebui/
│           │   ├── open-webui.container.tmpl
│           │   ├── ollama.container
│           │   ├── openwebui.pod
│           │   ├── openwebui.network
│           │   └── open-webui.service.d/
│           │       └── encrypted_env.age
│           │
│           └── monitoring/
│               ├── prometheus.container
│               ├── grafana.container.tmpl
│               └── monitoring.pod
│
└── run_after_apply.sh
```

## Resources

- [Chezmoi Documentation](https://www.chezmoi.io/)
- [Age Encryption](https://age-encryption.org/)
- [Podman Quadlet](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html)
