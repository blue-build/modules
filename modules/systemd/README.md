# `systemd` Module for Startingpoint

The `systemd` module streamlines the management of systemd units during image building. Units are divided into `system` and `user` categories, with `system` units managed directly using `systemctl` and `user` units using `systemctl --user`. You can specify which units to enable, disable or mask under each category.

## Example Configuration

```yaml
type: systemd
system:
  enabled:
    - example.service
  disabled:
    - example.target
  masked:
    - example.service
user:
  enabled:
    - example.timer
  disabled:
    - example.service
  masked:
    - example.service
```

In this example:

### System Units
- `example.service`: Enabled (runs on system boot)
- `example.target`: Disabled (does not run on system boot, unless other service strictly requires it)
- `example.service`: Masked (does not run on system boot, on any circumstances)

### User Units
- `example.timer`: Enabled (runs for the user)
- `example.service`: Disabled (does not run for the user, unless other service strictly requires it)
- `example.service`: Masked (does not run for the user, on any circumstances)

This configuration achieves the same results as the following commands:

```sh
# System Units
systemctl enable example.service
systemctl disable example.target
systemctl mask example.service 

# User Units
systemctl --user enable example.timer
systemctl --user disable example.service
systemctl --user mask example.service
```
