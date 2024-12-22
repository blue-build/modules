# `dnf`

The [`dnf`](https://docs.fedoraproject.org/en-US/quick-docs/dnf/) module offers pseudo-declarative package and repository management using `dnf`.

The module first downloads the repository files from URLs declared under `repos:` into `/etc/yum.repos.d/`. The magic string `%OS_VERSION%` can be substituted with the current VERSION_ID (major Fedora version), which can be used, for example, for pulling correct versions of repositories which have fixed Fedora version in the URL.

You can also add repository files directly into your git repository if URLs are not provided. For example:
```yml
repos:
   - my-repository.repo # copies in .repo file from files/dnf/my-repository.repo to /etc/yum.repos.d/
```

Specific COPR repositories can also be specified in `COPR user/project` format & is prefered over using direct COPR URL.

If you use a repo that requires adding custom keys (eg. Brave Browser), you can import the keys by declaring the key URLs under `keys:`. The magic string acts the same as it does in `repos`.

Then the module installs the packages declared under `install:` using `dnf -y install --refresh`, it removes the packages declared under `remove:` using `dnf -y remove`. If there are packages declared under both `install:` and `remove:` then removal is performed 1st & install 2nd.

Installing RPM packages directly from a `http(s)` url that points to the RPM file is also supported, you can just put the URLs under `install:` and they'll be installed along with the other packages. The magic string `%OS_VERSION%` is substituted with the current VERSION_ID (major Fedora version) like with the `repos:` property.

If an RPM is not available in a repository or as an URL, you can also install it directly from a file in your git repository. For example:
```yml
install:
   - weird-package.rpm # tries to install files/dnf/weird-package.rpm
```

Additionally, the `dnf` module supports a fix for packages that install into `/opt/`. Installation for packages that install into folder names declared under `optfix:` are fixed using some symlinks. Directory path in `/opt/` for those packages should be provided in recipe, like in Example Configuration.

There is an option to install & remove RPM groups if desired in `group-install:` & `group-remove:`. RPM groups removal & installation always run before packages removal & installation. To see the list of all available RPM groups, you can use `dnf group list` command.

The module can also replace base RPM packages with packages from any repo. Under `replace:`, the module finds every pair of keys `- from-repo:` and `packages:`. (Multiple pairs are supported.) The module uses `- from-repo:` key to gather the repo for package replacement, then it replaces packages declared under `packages:` using the command `dnf -y distro-sync --refresh --repo "${repo}" "${packages}"`. The magic string `%OS_VERSION%` is substituted with the current VERSION_ID (major Fedora version) as already said above. You need to assure that you provided the repo in `repos:` before using replacement functionality. To gather the repo ID that you need to input, you can use `dnf repo list` command.

:::note
[Removed packages are still present in the underlying ostree repository](https://coreos.github.io/rpm-ostree/administrator-handbook/#removing-a-base-package), what `remove` does is kind of like hiding them from the system, it doesn't free up storage space.
:::

There is also an `install-weak-dependencies:` option to enable or disable installation of weak dependencies for every install operation. Weak dependencies are installed by default. Which kind of dependencies are considered weak can be seen [here](https://docs.fedoraproject.org/en-US/packaging-guidelines/WeakDependencies/).
