FROM registry.fedoraproject.org/fedora:latest

RUN dnf update -y && dnf install wget -y && dnf clean all

RUN wget https://github.com/loft-sh/devpod/releases/latest/download/devpod-linux-amd64 -O /tmp/devpod && \
	install -c -m 0755 /tmp/devpod /usr/bin && \
	wget https://copr.fedorainfracloud.org/coprs/ganto/lxc4/repo/fedora-"${FEDORA_MAJOR_VERSION}"/ganto-lxc4-fedora-"${FEDORA_MAJOR_VERSION}".repo -O /etc/yum.repos.d/ganto-lxc4-fedora-"${FEDORA_MAJOR_VERSION}".repo && \
	wget https://terra.fyralabs.com/terra.repo -O /etc/yum.repos.d/terra.repo && \
	curl -s https://raw.githubusercontent.com/dnkmmr69420/nix-installer-scripts/main/installer-scripts/silverblue-nix-installer.sh -O /usr/bin/ublue-nix-install && \
	chmod +x /usr/bin/ublue-nix-install
