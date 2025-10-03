# `files`

The `files` module can be used to copy directories from `files/` to
any location in your image at build-time, as long as the location exists at
build-time (e.g. you can't put files in `/home/<username>/`, because users
haven't been created yet prior to first boot).

:::note
In run-time, `/usr/etc/` is the directory for "system"
configuration templates on atomic Fedora distros, whereas `/etc/` is meant for
manual overrides and editing by the machine's admin *after* installation.

In build-time, as a custom-image maintainer, you want to copy files to `/etc/`,
as those are automatically moved to system directory `/usr/etc/` during atomic Fedora image deployment.
Check out this blog post for more details about this:  
https://blue-build.org/blog/preferring-system-etc/
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
