# Simple Nginx Quadlet Example

This is a minimal example of a Podman Quadlet running nginx as a static file server.

## Files

- `nginx.container` - Main container definition
- `nginx.volume` - Persistent volume for web content
- `index.html` - Sample web page

## Usage

### Via BlueBuild Module

Add to your `recipe.yml`:

```yaml
- type: quadlets
  configurations:
    - name: nginx
      source: https://github.com/yourusername/your-quadlets-repo/tree/main/nginx
      scope: user
```

### Manual Installation

```bash
# Copy files to quadlets directory
mkdir -p ~/.config/containers/systemd/nginx
cp nginx.* ~/.config/containers/systemd/nginx/

# Create sample content
mkdir -p ~/nginx-data
echo "<h1>Hello from Nginx!</h1>" > ~/nginx-data/index.html

# Reload systemd and start
systemctl --user daemon-reload
systemctl --user start nginx.service
```

## Access

Once running, access at: http://localhost:8080

## Management

```bash
# Check status
systemctl --user status nginx.service

# View logs
journalctl --user -u nginx.service -f

# Stop
systemctl --user stop nginx.service

# Restart
systemctl --user restart nginx.service
```

## Customization

Edit `nginx.container` to:
- Change the published port
- Add environment variables
- Mount additional volumes
- Configure auto-updates
