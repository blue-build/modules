FROM registry.fedoraproject.org/fedora:latest AS builder

RUN dnf update -y && dnf install --disablerepo='*' --enablerepo='fedora,updates' --setopt install_weak_deps=0 --nodocs --assumeyes git wget unzip make rpm-build && dnf clean all

RUN mkdir -p /tmp/ublue-os/files/usr /tmp/ublue-os/{rpms,build}
COPY files /tmp/ublue-os/files
COPY build /tmp/ublue-os/build
ADD fetch.sh /tmp/fetch.sh

RUN chmod +x /tmp/fetch.sh && \
	/tmp/fetch.sh

# TODO: Eventually make this more flexible to include more projects
RUN cd /tmp/ublue-os/build/backgrounds && make && cp /tmp/ublue-os/rpmbuild/RPMS/noarch/*.rpm /tmp/ublue-os/rpms

FROM scratch

COPY --from=builder /tmp/ublue-os/files /files
COPY --from=builder /tmp/ublue-os/rpms /rpms
COPY --from=ghcr.io/ublue-os/ublue-update:latest /rpms/ublue-update.noarch.rpm /rpms
COPY modules /modules