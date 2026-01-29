# `systemd`

The `systemd` module streamlines the management of systemd units during image building. Units are divided into `system` and `user` categories, with `system` units managed directly using `systemctl` and `user` units using `systemctl --global`. You can specify which units to enable/disable or unmask/mask under each category.

You can also include your systemd units and [drop-in files](https://wiki.archlinux.org/title/Systemd#Drop-in_files) (allowing to override an existing unit) to be copied into system directories into these locations,  
depending if your unit is `system` or `user` based:  
`files/systemd/system/`  
`files/systemd/user/`

The found files are then copied into these folders (depending on unit base):  
`/usr/lib/systemd/system`  
`/usr/lib/systemd/user`

The directory structure will be preserved:
for example the file `files/systemd/system/getty@.d/autologin.conf` will be copied into `/usr/lib/system/getty@.d/`.

Supported management operations are [enabling](https://www.freedesktop.org/software/systemd/man/latest/systemctl.html#enable%20UNIT%E2%80%A6), [disabling](https://www.freedesktop.org/software/systemd/man/latest/systemctl.html#disable%20UNIT%E2%80%A6), [masking](https://www.freedesktop.org/software/systemd/man/latest/systemctl.html#mask%20UNIT%E2%80%A6%E2%80%A6) and [unmasking](https://www.freedesktop.org/software/systemd/man/latest/systemctl.html#unmask%20UNIT%E2%80%A6).
