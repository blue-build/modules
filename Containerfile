FROM registry.fedoraproject.org/fedora:latest AS builder

RUN dnf update -y && dnf install --disablerepo='*' --enablerepo='fedora,updates' --setopt install_weak_deps=0 --nodocs --assumeyes wget && dnf clean all

RUN mkdir -p /tmp/ublue-os/files/{etc,usr}
COPY usr /tmp/ublue-os/files/usr
COPY etc /tmp/ublue-os/files/etc

RUN wget "https://github.com/loft-sh/devpod/releases/latest/download/devpod-linux-amd64" -O /tmp/devpod && \
	install -c -m 0755 /tmp/devpod /tmp/ublue-os/files/usr/bin && \
	wget "https://terra.fyralabs.com/terra.repo" -O /tmp/ublue-os/files/etc/yum.repos.d/terra.repo && \
	curl -s "https://raw.githubusercontent.com/dnkmmr69420/nix-installer-scripts/main/installer-scripts/silverblue-nix-installer.sh" >> /tmp/ublue-nix-install && \
	install -c -m 0755 /tmp/ublue-nix-install /tmp/ublue-os/files/usr/bin

FROM scratch

COPY --from=builder /tmp/ublue-os/files /files

