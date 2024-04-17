# `files`

The `files` module can be used to copy directories from `config/files` to
any location in your image at build time, as long as the location exists at
build time (e.g. you can't put files in `/home/<username>`, because users
haven't been created yet prior to first boot).

:::note
If you want to place files into `/etc`, there are two ways to do it:

1. copying a directory in `config/files` directly to `/etc` to add all of its
   files at build time, or
2. putting the files you want there in `/usr/etc` as part of copying things
   over to `/usr`, which `rpm-ostree` will then copy to `/etc` at runtime/boot.

Typically, you will want to use the latter option (putting files in `/usr/etc`)
in almost all cases, since that is the proper directory for "system"
configuration templates on atomic Fedora distros, whereas `/etc` is meant for
manual overrides and editing by the machine's admin *after* installation (see
issue https://github.com/blue-build/legacy-template/issues/28). However, if you
really need something to be in `/etc` *at build time* --- for instance, if you
for some reason need to place a repo file in `/etc/yum.repos.d` in such a way
that it is used by a `rpm-ostree` module later on --- then the former option
will be necessary.
:::

:::caution
The `files` module **cannot write to directories that will later be symlinked
to point to other places (typically `/var`) by `rpm-ostree`**.

This is because it doesn't make sense for a directory to be both a symlink and
a real directory that has had actual files directly copied to it, so the
`files` module copying files to one of those directories (thereby instantiating
it as a real directory) and `rpm-ostree`'s behavior regarding them will
necessarily conflict.

For reference, according to the [official Fedora
documentation](https://docs.fedoraproject.org/en-US/fedora-silverblue/technical-information/#filesystem-layout),
here is a list of the directories that `rpm-ostree` symlinks to other
locations:

- `/home` → `/var/home`
- `/opt` → `/var/opt`
- `/srv` → `/var/srv`
- `/root` → `/var/roothome`
- `/usr/local` → `/var/usrlocal`
- `/mnt` → `/var/mnt`
- `/tmp` → `/sysroot/tmp`

So don't use `files` to copy any files to any of the directories on the left,
because at runtime `rpm-ostree` will want to link them to the ones on the
right, which will cause a conflict as explained above.

:::
