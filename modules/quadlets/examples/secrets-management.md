# Secrets Management for Quadlets

## Overview

Quadlets often need sensitive data like API keys, passwords, and certificates. This guide covers various approaches to managing secrets securely with the quadlets module.

## Methods

### 1. Podman Secrets (Recommended for Simple Cases)

Podman has built-in secrets management:

```bash
# Create a secret
echo "my-api-key" | podman secret create openai_api_key -

# Use in quadlet
```

**`open-webui.container`**:
```ini
[Container]
Image=ghcr.io/open-webui/open-webui:latest
Secret=openai_api_key,type=env,target=OPENAI_API_KEY
```

**Pros:**
- Native Podman feature
- Simple to use
- Encrypted at rest

**Cons:**
- Not easily version controlled
- Manual setup on each machine
- Limited to environment variables and files

### 2. Age + Chezmoi (Recommended for Complex Setups)

Use Age encryption with chezmoi for full dotfile management. See [Chezmoi Integration Guide](./chezmoi-integration.md) for details.

**Pros:**
- Version controlled (encrypted)
- Supports templates
- Works with entire dotfile ecosystem

**Cons:**
- Requires manual decryption step on first boot
- More complex setup

### 3. Environment Files (Simple, Less Secure)

Store secrets in environment files with restricted permissions:

```bash
# Create env file
cat > ~/.config/containers/systemd/openwebui/.env << EOF
OPENAI_API_KEY=sk-...
DATABASE_PASSWORD=...
EOF

# Restrict permissions
chmod 600 ~/.config/containers/systemd/openwebui/.env
```

**`open-webui.container`**:
```ini
[Container]
Image=ghcr.io/open-webui/open-webui:latest
EnvironmentFile=%h/.config/containers/systemd/openwebui/.env
```

**Pros:**
- Simple to implement
- Easy to edit

**Cons:**
- Secrets stored in plaintext
- Not suitable for version control
- Easy to accidentally expose

### 4. External Secret Managers

Integrate with external secret managers like Vault or Bitwarden.

**Example with Bitwarden CLI:**

**`secrets-loader.sh`**:
```bash
#!/bin/bash
# Load secrets from Bitwarden and create env file

bw login
bw unlock --passwordenv BW_PASSWORD

# Fetch secrets
OPENAI_KEY=$(bw get password openai-api-key)
DB_PASSWORD=$(bw get password openwebui-db)

# Create env file
cat > ~/.config/containers/systemd/openwebui/.env << EOF
OPENAI_API_KEY=$OPENAI_KEY
DATABASE_PASSWORD=$DB_PASSWORD
EOF

chmod 600 ~/.config/containers/systemd/openwebui/.env

# Lock vault
bw lock
```

**Setup as systemd service:**

**`secrets-loader.service`**:
```ini
[Unit]
Description=Load secrets for Open WebUI
Before=user-quadlets-setup.service

[Service]
Type=oneshot
ExecStart=/home/user/bin/secrets-loader.sh
Environment=BW_SESSION=...

[Install]
WantedBy=default.target
```

**Pros:**
- Centralized secret management
- Audit logging
- Enterprise-grade security

**Cons:**
- More complex infrastructure
- Additional dependencies
- Network dependency

### 5. SOPS (Secrets OPerationS)

Use Mozilla SOPS for encrypted files in Git:

```bash
# Install sops
dnf install sops

# Configure .sops.yaml
cat > .sops.yaml << EOF
creation_rules:
  - path_regex: \.env$
    age: age1...
EOF

# Encrypt env file
sops -e .env > .env.encrypted

# Decrypt at runtime
sops -d .env.encrypted > .env
```

**Integration script:**

**`decrypt-secrets.sh`**:
```bash
#!/bin/bash
QUADLET_DIR=~/.config/containers/systemd/openwebui

sops -d "$QUADLET_DIR/.env.encrypted" > "$QUADLET_DIR/.env"
chmod 600 "$QUADLET_DIR/.env"
```

**Pros:**
- Git-friendly encryption
- Supports multiple backends (Age, GPG, cloud KMS)
- Fine-grained encryption (can encrypt specific keys)

**Cons:**
- Another tool to learn
- Requires decryption step

## Comparison Matrix

| Method | Security | Ease of Use | Version Control | Multi-Machine |
|--------|----------|-------------|-----------------|---------------|
| Podman Secrets | High | Easy | No | Manual |
| Age + Chezmoi | High | Medium | Yes | Easy |
| Env Files | Low | Very Easy | No | Manual |
| External Manager | Very High | Complex | N/A | Easy |
| SOPS | High | Medium | Yes | Easy |

## Best Practices

### 1. Never Commit Plaintext Secrets

Add to `.gitignore`:
```
*.env
*secret*
*password*
*.key
```

### 2. Use Restrictive Permissions

```bash
# Environment files
chmod 600 ~/.config/containers/systemd/*/.env

# Key files
chmod 600 ~/.config/age/key.txt
```

### 3. Rotate Secrets Regularly

Create a rotation script:

```bash
#!/bin/bash
# rotate-secrets.sh

# Generate new API key
NEW_KEY=$(generate-api-key)

# Update in secret manager
podman secret rm openai_api_key
echo "$NEW_KEY" | podman secret create openai_api_key -

# Restart affected services
systemctl --user restart openwebui.service
```

### 4. Audit Secret Access

Monitor who accesses secrets:

```bash
# Check which containers use which secrets
podman container inspect --format '{{.Config.Secrets}}' open-webui

# Monitor access logs
journalctl --user -u openwebui.service | grep -i secret
```

### 5. Use Different Secrets Per Environment

**Development:**
```ini
EnvironmentFile=%h/.config/containers/systemd/openwebui/.env.dev
```

**Production:**
```ini
EnvironmentFile=%h/.config/containers/systemd/openwebui/.env.prod
```

### 6. Implement Backup Encryption

Backup secrets separately and encrypted:

```bash
# Backup and encrypt
tar czf secrets-backup.tar.gz ~/.config/containers/systemd/*/.env
age -e -o secrets-backup.tar.gz.age -i ~/.config/age/key.txt secrets-backup.tar.gz
rm secrets-backup.tar.gz
```

## Integration with Quadlets Module

### Configuration for External Management

```yaml
type: quadlets
configurations:
  - name: openwebui
    source: ~/.config/containers/systemd/openwebui
    scope: user
    managed-externally: true
    setup-delay: 15m  # Longer delay for secret decryption
```

### Pre-Setup Hook

Create a systemd service that runs before quadlet setup:

**`prepare-secrets.service`**:
```ini
[Unit]
Description=Prepare secrets for quadlets
Before=user-quadlets-setup.service

[Service]
Type=oneshot
ExecStart=/home/user/bin/decrypt-secrets.sh

[Install]
WantedBy=default.target
```

Enable it:
```bash
systemctl --user enable prepare-secrets.service
```

## Troubleshooting

### Secret not available

```bash
# List podman secrets
podman secret ls

# Inspect secret (doesn't show value)
podman secret inspect openai_api_key

# Check container has access
podman container inspect open-webui | grep -A5 Secrets
```

### Permission denied

```bash
# Fix file permissions
chmod 600 ~/.config/containers/systemd/*/.env

# Fix directory permissions
chmod 700 ~/.config/containers/systemd/*/
```

### Age decryption fails

```bash
# Verify key file exists
ls -la ~/.config/age/key.txt

# Test decryption manually
age -d -i ~/.config/age/key.txt < encrypted-file

# Check chezmoi config
chezmoi doctor
```

## Example: Complete Secret Setup

### 1. Create Age Key

```bash
mkdir -p ~/.config/age
age-keygen -o ~/.config/age/key.txt
chmod 600 ~/.config/age/key.txt

# Backup to USB
cp ~/.config/age/key.txt /mnt/usb/backup-key.txt
```

### 2. Encrypt Environment File

```bash
cat > openwebui.env << EOF
OPENAI_API_KEY=sk-...
OLLAMA_API_KEY=...
DATABASE_PASSWORD=...
EOF

age -e -o openwebui.env.age -i ~/.config/age/key.txt openwebui.env
rm openwebui.env
```

### 3. Add to Chezmoi

```bash
chezmoi add --encrypt ~/.config/containers/systemd/openwebui/.env
```

### 4. Configure Quadlet Module

```yaml
type: quadlets
configurations:
  - name: openwebui
    source: ~/.config/containers/systemd/openwebui
    scope: user
    managed-externally: true
    setup-delay: 10m
```

### 5. First Boot Workflow

```bash
# 1. Mount USB
mount /dev/sdb1 /mnt/usb

# 2. Apply chezmoi
export CHEZMOI_AGE_KEY_FILE=/mnt/usb/backup-key.txt
chezmoi apply

# 3. Verify secrets
cat ~/.config/containers/systemd/openwebui/.env

# 4. Trigger quadlet setup
bluebuild-quadlets-manager discover
```

## Resources

- [Podman Secrets](https://docs.podman.io/en/latest/markdown/podman-secret.1.html)
- [Age Encryption](https://age-encryption.org/)
- [Mozilla SOPS](https://github.com/mozilla/sops)
- [Chezmoi Templates](https://www.chezmoi.io/user-guide/templating/)
