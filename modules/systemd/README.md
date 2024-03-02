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
`config/systemd/system.conf.d/`  
`config/systemd/user.conf.d/`  
`config/systemd/zram-generator.conf.d/`

Which are then copied into these folders:  
`/usr/lib/systemd/system.conf.d/`  
`/usr/lib/systemd/user.conf.d/`  
`/usr/lib/systemd/zram-generator.conf.d/`

Supported systemd unit management operations are:  
[enabling](https://www.freedesktop.org/software/systemd/man/latest/systemctl.html#enable%20UNIT%E2%80%A6)  
[disabling](https://www.freedesktop.org/software/systemd/man/latest/systemctl.html#disable%20UNIT%E2%80%A6)  
[masking](https://www.freedesktop.org/software/systemd/man/latest/systemctl.html#mask%20UNIT%E2%80%A6%E2%80%A6)
[unmasking](https://www.freedesktop.org/software/systemd/man/latest/systemctl.html#unmask%20UNIT%E2%80%A6)

Supported systemd configs are:  
[system.conf & user.conf](https://www.freedesktop.org/software/systemd/man/latest/systemd-system.conf.html)  
[zram-generator.conf.d](https://github.com/systemd/zram-generator)

## Config files usage

### System.conf & user.conf config

System.conf & user.conf config files can be used to modify default systemd behaviour related to service logging, service timeout, resource limits, OOM killer & other related options.  
Some of those options affect system globally, not just systemd services only.  

System.conf applies settings at the system level, while user.conf applies settings at the user level.

If you use ulimit to apply certain settings, config files can apply those too, in [this equivalent format.](https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#Process%20Properties)  
1KB = 1024B format is used.

List of all available options & what they do are outlined in "Supported systemd configs" section.

Take a note that literal system.conf & user.conf files exist, but this module places them in `.d` suffixed folder, as an officially supported drop-in.  
So don't edit those 2 files, as they are used by Linux distribution.

Config file can be named however you please, but it must have .conf extension.

"[Manager]" must be always present at the beggining of the config file.

Example of system.conf/user.conf drop-in config file:
```
[Manager]
DefaultLimitMEMLOCK=2199023616
```
Applies higher MemLock limit to 2.048GB, which can be used if certain application requires it (like [RPCS3 emulator](https://github.com/RPCS3/rpcs3/issues/9328)).

### ZRAM Generator config

ZRAM Generator config file can be used to modify default ZRAM behavior with various settings, like it's maximal size, dynamic size, compression algorithm & similar.

Example of all available ZRAM Generator options & how they should be used is outlined [here](https://github.com/systemd/zram-generator/blob/main/zram-generator.conf.example).

Config file can be named however you please, but it must have .conf extension.

Example of zram-generator config file:
```
[zram0]
zram-size=min(ram, 16384)
compression-algorithm=zstd
```
Applies ZRAM settings to default ZRAM device with:
- ZRAM Size, which mathes host RAM size, but without crossing 16GB limit 
- ZSTD Compression algorithm
