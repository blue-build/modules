#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -oue pipefail

install -c -m 0755 "$BLING_DIRECTORY/files/usr/bin/docker-compose" "/usr/bin/docker-compose"
install -c -m 0755 "$BLING_DIRECTORY/files/usr/bin/kind" "/usr/bin/kind"
install -c -m 0755 "$BLING_DIRECTORY/files/usr/bin/kubectx" "/usr/bin/kubectx"
install -c -m 0755 "$BLING_DIRECTORY/files/usr/bin/kubectx" "/usr/bin/kubens" 
rpm-ostree install "$BLING_DIRECTORY"/rpms/dive*.rpm

