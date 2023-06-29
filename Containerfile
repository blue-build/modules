FROM registry.fedoraproject.org/fedora:latest AS builder

RUN dnf update -y && dnf install --disablerepo='*' --enablerepo='fedora,updates' --setopt install_weak_deps=0 --nodocs --assumeyes wget && dnf clean all

RUN mkdir -p /tmp/ublue-os/files/{etc,usr}

COPY usr /tmp/ublue-os/files/usr
COPY etc /tmp/ublue-os/files/etc
ADD fetch.sh /tmp/fetch.sh

RUN chmod +x /tmp/fetch.sh && \
	/tmp/fetch.sh

FROM scratch

COPY --from=builder /tmp/ublue-os/files /files
COPY --from=builder /tmp/ublue-os/rpms /rpms
