# `files`

The `files` module can be used to copy directories from `files/` to
any location in your image at build-time, as long as the location exists at
build-time (e.g. you can't put files in `/home/<username>/`, because users
haven't been created yet prior to first boot).

:::note
Don't copy files directly to `/usr/etc/` in build-time, but copy those to `/etc/` instead,
due to the nature of how `ostree` handles `/usr/etc/` & `/etc/` relationship.

`/usr/etc/` is empty in build-time, while `/etc/` is populated from the base image & changes that you do to it afterwards.
`/etc/` is then automatically merged to `/usr/etc/` in build-time by `ostree`.

So this means that copying files to `/etc/` in build-time is actually copying it to `/usr/etc/` as an end result.

While copying files to `/usr/etc/` directly in build-time didn't cause any harm,
the mentioned way above is the more correct one.

In run-time, `/usr/etc/` is the directory for "system"
configuration templates on atomic Fedora distros, whereas `/etc/` is meant for
manual overrides and editing by the machine's admin *after* installation.
:::

:::caution
The `files` module **cannot write to directories that will later be symlinked
to point to other places (typically `/var/`) by `rpm-ostree`**.

This is because it doesn't make sense for a directory to be both a symlink and
a real directory that has had actual files directly copied to it, so the
`files` module copying files to one of those directories (thereby instantiating
it as a real directory) and `rpm-ostree`'s behavior regarding them will
necessarily conflict.

For reference, according to the [official Fedora
documentation](https://docs.fedoraproject.org/en-US/fedora-silverblue/technical-information/#filesystem-layout),
here is a list of the directories that `rpm-ostree` symlinks to other
locations:

- `/home/` → `/var/home/`
- `/opt/` → `/var/opt/`
- `/srv/` → `/var/srv/`
- `/root/` → `/var/roothome/`
- `/usr/local/` → `/var/usrlocal/`
- `/mnt/` → `/var/mnt/`
- `/tmp/` → `/sysroot/tmp/`

So don't use `files` to copy any files to any of the directories on the left,
because at runtime `rpm-ostree` will want to link them to the ones on the
right, which will cause a conflict as explained above.

:::
