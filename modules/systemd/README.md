# `systemd` Module for Startingpoint

The `systemd` module streamlines the management of systemd units during image building. Units are divided into `system` and `user` categories, with `system` units managed directly using `systemctl` and `user` units using `systemctl --user`. You can specify which units to enable/disable or unmask/mask under each category.

## Example Configuration

```yaml
type: systemd
system:
  enabled:
    - example.service
  disabled:
    - example.target
  unmasked:
    - example.service    
  masked:
    - example.service
user:
  enabled:
    - example.timer
  disabled:
    - example.service
  unmasked:
    - example.service    
  masked:
    - example.service
```

In this example:

### System Units
- `example.service`: Enabled (runs on system boot)
- `example.target`: Disabled (does not run on system boot, unless other unit strictly requires it)
- `example.service`: Unmasked (runs on system boot, even if previously masked)
- `example.service`: Masked (does not run on system boot, under any circumstances)

### User Units
- `example.timer`: Enabled (runs for the user)
- `example.service`: Disabled (does not run for the user, unless other unit strictly requires it)
- `example.service`: Unmasked (runs for the user, even if previously masked)
- `example.service`: Masked (does not run for the user, under any circumstances)

This configuration achieves the same results as the following commands:

```sh
# System Units
systemctl enable example.service
systemctl disable example.target
systemctl unmask example.service 
systemctl mask example.service 

# User Units
systemctl --global enable example.timer
systemctl --global disable example.service
systemctl --global unmask example.service
systemctl --global mask example.service
```

For more information about these systemctl commands, please visit: 
https://www.freedesktop.org/software/systemd/man/latest/systemctl.html#enable%20UNIT%E2%80%A6
https://www.freedesktop.org/software/systemd/man/latest/systemctl.html#disable%20UNIT%E2%80%A6
https://www.freedesktop.org/software/systemd/man/latest/systemctl.html#unmask%20UNIT%E2%80%A6
https://www.freedesktop.org/software/systemd/man/latest/systemctl.html#mask%20UNIT%E2%80%A6
