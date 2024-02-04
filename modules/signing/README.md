# `signing`

The `signing` module is used to install the required signing policies for cosign image verification with [`rpm-ostree`](https://github.com/coreos/rpm-ostree) and [`bootc`](https://github.com/containers/bootc). This module is the successor to the `signing.sh` script that previously existed in the template. This module also allows for basing off of non-Universal-Blue Fedora base images.