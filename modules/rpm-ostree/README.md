# `rpm-ostree`

The [`rpm-ostree`](https://coreos.github.io/rpm-ostree/) module offers pseudo-declarative package and repository management using `rpm-ostree`.

The module first downloads the repository files from URLs declared under `repos:` into `/etc/yum.repos.d/`. The magic string `%OS_VERSION%` is substituted with the current VERSION_ID (major Fedora version), which can be used, for example, for pulling correct versions of repositories from [Fedora's Copr](https://copr.fedorainfracloud.org/).

You can also add repository files directly into your git repository if URLs are not provided. For example:
```yml
repos:
   - my-repository.repo # copies in .repo file from files/rpm-ostree/my-repository.repo to /etc/yum.repos.d/
```
If you use a repo that requires adding custom keys (eg. Brave Browser), you can import the keys by declaring the key URLs under `keys:`. The magic string acts the same as it does in `repos`.

Then the module installs the packages declared under `install:` using `rpm-ostree install`, it removes the packages declared under `remove:` using `rpm-ostree override remove`. If there are packages declared under both `install:` and `remove:` a hybrid command `rpm-ostree remove <packages> --install <packages>` is used, which should allow you to switch required packages for other ones.

Installing RPM packages directly from a `http(s)` url that points to the RPM file is also supported, you can just put the URLs under `install:` and they'll be installed along with the other packages. The magic string `%OS_VERSION%` is substituted with the current VERSION_ID (major Fedora version) like with the `repos:` property.

If an RPM is not available in a repository or as an URL, you can also install it directly from a file in your git repository. For example:
```yml
install:
   - weird-package.rpm # tries to install files/rpm-ostree/weird-package.rpm
```
The module can also replace base RPM packages with packages from COPR repo. Under `replace:`, the module finds every pair of keys `- from-repo:` and `packages:`. (Multiple pairs are supported.) The module downloads the COPR repository file declared by `- from-repo:` into `/etc/yum.repos.d/`, and from that repository replaces packages declared under `packages:` using the command `rpm-ostree override replace`. The COPR repository file is then deleted. The magic string `%OS_VERSION%` is substituted with the current VERSION_ID (major Fedora version) as already said above. At the moment, only COPR repo is supported.

:::note
[Removed packages are still present in the underlying ostree repository](https://coreos.github.io/rpm-ostree/administrator-handbook/#removing-a-base-package), what `remove` does is kind of like hiding them from the system, it doesn't free up storage space.
:::

Additionally, the `rpm-ostree` module supports a temporary (waiting for `rpm-ostree` issue [#233](https://github.com/coreos/rpm-ostree/issues/233)) fix for packages that install into `/opt/`. Installation for packages that install into folder names declared under `optfix:` are fixed using some symlinks. Directory path in `/opt/` for those packages should be provided in recipe, like in Example Configuration.

## Known issues

When removing certain packages, some problem probably in upstream `rpm-ostree` causes a `depsolve` issue similar to below.
```
Resolving dependencies...done
error: Could not depsolve transaction; 1 problem detected:
Problem: conflicting requests
```
