# `systemd`

The `systemd` module streamlines the management of systemd units during image building. Units are divided into `system` and `user` categories, with `system` units managed directly using `systemctl` and `user` units using `systemctl --global`. You can specify which units to enable/disable or unmask/mask under each category.

You can also include your systemd units to be copied into system directories into these locations,  
depending if your unit is `system` or `user` based:  
`config/systemd/system`  
`config/systemd/user`

Those units are then copied into these folders (depending on unit base):  
`/usr/lib/systemd/system`  
`/usr/lib/systemd/user`

Specific systemd config can be included in these directories, depending on certain usecases:  
`config/systemd/system.conf.d`  
`config/systemd/user.conf.d`  
`config/systemd/zram-generator.conf.d`

Which are then copied into these folders:  
`/usr/lib/systemd/system.conf.d`  
`/usr/lib/systemd/user.conf.d`  
`/usr/lib/systemd/zram-generator.conf.d`

Supported systemd unit management operations are:  
 [enabling](https://www.freedesktop.org/software/systemd/man/latest/systemctl.html#enable%20UNIT%E2%80%A6)  
[disabling](https://www.freedesktop.org/software/systemd/man/latest/systemctl.html#disable%20UNIT%E2%80%A6)  
[masking](https://www.freedesktop.org/software/systemd/man/latest/systemctl.html#mask%20UNIT%E2%80%A6%E2%80%A6  
[unmasking](https://www.freedesktop.org/software/systemd/man/latest/systemctl.html#unmask%20UNIT%E2%80%A6)

Supported systemd configs are:  
[system.conf.d & user.conf.d](https://www.freedesktop.org/software/systemd/man/latest/systemd-system.conf.html)  
[zram-generator.conf.d](https://github.com/systemd/zram-generator/blob/main/zram-generator.conf.example)

