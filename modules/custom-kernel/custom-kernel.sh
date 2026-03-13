#!/usr/bin/env bash
set -euo pipefail

log() {
    local PREFIX="[custom-kernel]"
    # local BOLD_CYAN='\033[1;36m'
    # local RESET='\033[0m'
    # echo -e "${BOLD_CYAN}${PREFIX}${RESET} $*"
    echo -e "${PREFIX} $*"
}

error() {
    local PREFIX="[custom-kernel] Error:"
    # local BOLD_RED='\033[1;31m'
    # local RESET='\033[0m'
    # echo -e "${BOLD_RED}${PREFIX}${RESET} $*"
    echo -e "${PREFIX} $*"
}
log "Starting custom-kernel module..."

# Read configuration from the first argument ($1) using jq
KERNEL_TYPE=$(echo "$1" | jq -r '.kernel // "cachyos-lto"')
INITRAMFS=$(echo "$1" | jq -r '.initramfs // false')
NVIDIA=$(echo "$1" | jq -r '.nvidia // false')
SIGNING_KEY=$(echo "$1" | jq -r '.sign.key // ""')
SIGNING_CERT=$(echo "$1" | jq -r '.sign.cert // ""')
MOK_PASSWORD=$(echo "$1" | jq -r '.sign.["mok-password"] // ""')
SECURE_BOOT=false

# Checking key, cert and password. Can't continue without them
if [[ -z "${SIGNING_KEY}" && -z "${SIGNING_CERT}" && -z "${MOK_PASSWORD}" ]]; then
    log "SecureBoot signing disabled."
elif [[ -f "${SIGNING_KEY}" && -f "${SIGNING_CERT}" && -n "${MOK_PASSWORD}" ]]; then
    log "SecureBoot signing enabled."
    SECURE_BOOT=true
else
    error "Invalid signing config:"
    error "  sign.key:  ${SIGNING_KEY:-<empty>}"
    error "  sign.cert:  ${SIGNING_CERT:-<empty>}"
    error "  sign.mok-password: ${MOK_PASSWORD:-<empty>}"
    exit 1
fi

# Double check everything about keys and certs
if [[ ${SECURE_BOOT} == true ]]; then
    openssl pkey -in "${SIGNING_KEY}" -noout >/dev/null 2>&1 \
        || { error "sign.key is not a valid private key"; exit 1; }

    openssl x509 -in "${SIGNING_CERT}" -noout >/dev/null 2>&1 \
        || { error "sign.cert is not a valid X509 cert"; exit 1; }

    if ! diff -q \
        <(openssl pkey -in "${SIGNING_KEY}" -pubout) \
        <(openssl x509 -in "${SIGNING_CERT}" -pubkey -noout); then
        error "sign.key and sign.cert do not match"
        exit 1
    fi
fi

# Resolve kernel settings based on the kernel type
COPR_REPOS=()
KERNEL_PACKAGES=()
EXTRA_PACKAGES=(
    akmods
)

case "${KERNEL_TYPE}" in
cachyos-lto)
    COPR_REPOS=(
        bieszczaders/kernel-cachyos-lto
    )
    KERNEL_PACKAGES=(
        kernel-cachyos-lto
        kernel-cachyos-lto-core
        kernel-cachyos-lto-modules
        kernel-cachyos-lto-devel-matched
    )
    ;;
cachyos-lts-lto)
    COPR_REPOS=(
        bieszczaders/kernel-cachyos-lto
    )
    KERNEL_PACKAGES=(
        kernel-cachyos-lts-lto
        kernel-cachyos-lts-lto-core
        kernel-cachyos-lts-lto-modules
        kernel-cachyos-lts-lto-devel-matched
    )
    ;;
cachyos)
    COPR_REPOS=(
        bieszczaders/kernel-cachyos
    )
    KERNEL_PACKAGES=(
        kernel-cachyos
        kernel-cachyos-core
        kernel-cachyos-modules
        kernel-cachyos-devel-matched
    )
    ;;
cachyos-rt)
    COPR_REPOS=(
        bieszczaders/kernel-cachyos
    )
    KERNEL_PACKAGES=(
        kernel-cachyos-rt
        kernel-cachyos-rt-core
        kernel-cachyos-rt-modules
        kernel-cachyos-rt-devel-matched
    )
    ;;
cachyos-lts)
    COPR_REPOS=(
        bieszczaders/kernel-cachyos
    )
    KERNEL_PACKAGES=(
        kernel-cachyos-lts
        kernel-cachyos-lts-core
        kernel-cachyos-lts-modules
        kernel-cachyos-lts-devel-matched
    )
    ;;
*)
    error "Unsupported kernel type: ${KERNEL_TYPE}"
    exit 1
    ;;
esac

restore_kernel_install_hooks() {
    local RPMOSTREE=/usr/lib/kernel/install.d/05-rpmostree.install
    local DRACUT=/usr/lib/kernel/install.d/50-dracut.install

    if [[ -f "${RPMOSTREE}.bak" ]]; then
        mv -f "${RPMOSTREE}.bak" "${RPMOSTREE}"
    fi

    if [[ -f "${DRACUT}.bak" ]]; then
        mv -f "${DRACUT}.bak" "${DRACUT}"
    fi
}

disable_kernel_install_hooks() {
    local RPMOSTREE=/usr/lib/kernel/install.d/05-rpmostree.install
    local DRACUT=/usr/lib/kernel/install.d/50-dracut.install

    if [[ -f "${RPMOSTREE}" ]]; then
        mv "${RPMOSTREE}" "${RPMOSTREE}.bak"
        printf '%s\n' '#!/bin/sh' 'exit 0' >"${RPMOSTREE}"
        chmod +x "${RPMOSTREE}"
    fi

    if [[ -f "${DRACUT}" ]]; then
        mv "${DRACUT}" "${DRACUT}.bak"
        printf '%s\n' '#!/bin/sh' 'exit 0' >"${DRACUT}"
        chmod +x "${DRACUT}"
    fi
}

# Installing custom kernel
log "Temporarily disabling kernel install scripts."
disable_kernel_install_hooks

log "Removing default kernel packages."
dnf -y remove \
    kernel \
    kernel-core \
    kernel-modules \
    kernel-modules-core \
    kernel-modules-extra \
    kernel-devel \
    kernel-devel-matched || true
rm -rf /usr/lib/modules/* || true

for repo in "${COPR_REPOS[@]}"; do
    log "Enabling COPR repo: ${repo}"
    dnf -y copr enable "${repo}"
done

log "Installing kernel packages: ${KERNEL_PACKAGES[*]}"
dnf -y install \
    "${KERNEL_PACKAGES[@]}" \
    "${EXTRA_PACKAGES[@]}"

KERNEL_VERSION="$(rpm -q "${KERNEL_PACKAGES[0]}" --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')" || exit 1
log "Detected kernel version: ${KERNEL_VERSION}"

log "Restoring kernel install scripts."
restore_kernel_install_hooks

log "Cleaning up custom kernel repos."
rm -f /etc/yum.repos.d/*copr*

# Install Nvidia if needed
disable_akmodsbuild() {
    local AK="/usr/sbin/akmodsbuild"
    local BAK="${AK}.backup"

    if [[ ! -f "${AK}" ]]; then
        error "akmodsbuild not found: ${AK}"
        return 1
    fi

    cp -a "${AK}" "${BAK}" || return 1

    # remove the problematic block
    sed -i '/if \[\[ -w \/var \]\] ; then/,/fi/d' "${AK}" || return 1
}

restore_akmodsbuild() {
    local AK="/usr/sbin/akmodsbuild"
    local BAK="${AK}.backup"

    if [[ -f "${BAK}" ]]; then
        mv -f "${BAK}" "${AK}"
    fi
}

if [[ ${NVIDIA} == true ]]; then
    log "Enabling Nvidia repositories."
    curl -fsSL --retry 5 --create-dirs \
        https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo \
        -o /etc/yum.repos.d/nvidia-container-toolkit.repo
    curl -fsSL --retry 5 --create-dirs \
        https://negativo17.org/repos/fedora-nvidia.repo \
        -o /etc/yum.repos.d/fedora-nvidia.repo
        

    log "Temporarily disabling akmodsbuild script."
    disable_akmodsbuild || exit 1

    log "Building and installing Nvidia kernel module packages."    
    dnf install -y --setopt=install_weak_deps=False --setopt=tsflags=noscripts \
        akmod-nvidia \
        nvidia-kmod-common \
        nvidia-modprobe \
        gcc-c++
    akmods --force --verbose --kernels "${KERNEL_VERSION}" --kmod "nvidia"
    
    # akmods always fails with exit 0 so we have to check explicitly
    FAIL_LOG_GLOB=/var/cache/akmods/nvidia/*-for-${KERNEL_VERSION}.failed.log

    shopt -s nullglob
    FAIL_LOGS=( ${FAIL_LOG_GLOB} )
    shopt -u nullglob

    if (( ${#FAIL_LOGS[@]} )); then
        error "Nvidia akmod build failed"
        for f in "${FAIL_LOGS[@]}"; do
            cat "${f}" || log "Failed to read ${f}"
            log "--------------"
        done
        exit 1
    fi

    log "Restoring akmodsbuild script."
    restore_akmodsbuild

    log "Installing Nvidia userspace packages."
    dnf install -y --setopt=skip_unavailable=1 \
        libva-nvidia-driver \
        nvidia-driver \
        nvidia-persistenced \
        nvidia-settings \
        nvidia-driver-cuda \
        libnvidia-cfg \
        libnvidia-fbc \
        libnvidia-ml \
        libnvidia-gpucomp \
        nvidia-driver-libs.i686 \
        nvidia-driver-cuda-libs.i686 \
        libnvidia-fbc.i686 \
        libnvidia-ml.i686 \
        libnvidia-gpucomp.i686 \
        nvidia-container-toolkit

    log "Cleaning Nvidia repositories."
    rm -f /etc/yum.repos.d/*nvidia*

    log "Installing Nvidia SELinux policy."
    curl -fsSL --retry 5 --create-dirs \
        https://raw.githubusercontent.com/NVIDIA/dgx-selinux/master/bin/RHEL9/nvidia-container.pp \
        -o nvidia-container.pp
    semodule -i nvidia-container.pp
    rm -f nvidia-container.pp

    log "Installing Nvidia container toolkit service and preset."
    install -D -m 0644 /dev/stdin /usr/lib/systemd/system/nvctk-cdi.service <<'EOF'
[Unit]
Description=NVIDIA Container Toolkit CDI auto-generation
ConditionFileIsExecutable=/usr/bin/nvidia-ctk
ConditionPathExists=!/etc/cdi/nvidia.yaml
After=local-fs.target

[Service]
Type=oneshot
ExecStart=/usr/bin/nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml

[Install]
WantedBy=multi-user.target
EOF

    install -D -m 0644 /dev/stdin /usr/lib/systemd/system-preset/70-nvctk-cdi.preset <<'EOF'
enable nvctk-cdi.service
EOF

    log "Setting up Nvidia modules."
    install -D -m 0644 /dev/stdin /etc/modprobe.d/nvidia.conf <<'EOF'
blacklist nouveau
options nouveau modeset=0
options nvidia-drm modeset=1 fbdev=1
EOF

    log "Setting up GPU modules for initramfs."
    install -D -m 0644 /dev/stdin /usr/lib/dracut/dracut.conf.d/99-nvidia.conf <<'EOF'
# Force the i915 amdgpu nvidia drivers to the ramdisk
force_drivers+=" i915 amdgpu nvidia nvidia_drm nvidia_modeset nvidia_peermem nvidia_uvm "
EOF

    log "Injecting Nvidia kernel args"
    install -D -m 0644 /dev/stdin /usr/lib/bootc/kargs.d/90-nvidia.toml <<'EOF'
kargs = [
"rd.driver.blacklist=nouveau",
"modprobe.blacklist=nouveau",
"rd.driver.pre=nvidia",
"nvidia-drm.modeset=1",
"nvidia-drm.fbdev=1"
]
EOF
fi

# Sign the kernel and modules
sign_kernel() {
    local MODULE_ROOT="/usr/lib/modules/${KERNEL_VERSION}"
    local VMLINUZ="${MODULE_ROOT}/vmlinuz"

    # Sign kernel
    if [[ -f "${VMLINUZ}" ]]; then
        log "Kernel image: ${VMLINUZ}"

        SIGNED_VMLINUZ="$(mktemp)"

        # Sign kernel into temp file
        sbsign \
            --key  "${SIGNING_KEY}" \
            --cert "${SIGNING_CERT}" \
            --output "${SIGNED_VMLINUZ}" \
            "${VMLINUZ}"

        # Verify signature before installing
        if ! sbverify --cert "${SIGNING_CERT}" "${SIGNED_VMLINUZ}"; then
            error "Kernel signature verification failed"
            rm -f "${SIGNED_VMLINUZ}"
            return 1
        fi

        log "Verification successful. Installing signed kernel."

        # Atomically replace original kernel with signed one
        install -m 0644 "${SIGNED_VMLINUZ}" "${VMLINUZ}"
        rm -f "${SIGNED_VMLINUZ}"
    else
        error "Can't find kernel image: ${VMLINUZ}"
        return 1
    fi

    # For final check later
    sha256sum "${VMLINUZ}" > /tmp/vmlinuz.sha
}

sign_kernel_modules() {
    local MODULE_ROOT="/usr/lib/modules/${KERNEL_VERSION}"
    local SIGN_FILE="${MODULE_ROOT}/build/scripts/sign-file"

    if [[ ! -x "${SIGN_FILE}" ]]; then
        error "sign-file not found or not executable: ${SIGN_FILE}"
        return 1
    fi

    while IFS= read -r -d '' mod; do
        case "${mod}" in
        *.ko)
            "${SIGN_FILE}" sha256 "${SIGNING_KEY}" "${SIGNING_CERT}" "${mod}" || return 1
            ;;
        *.ko.xz)
            xz -d -q "${mod}"
            raw="${mod%.xz}"
            "${SIGN_FILE}" sha256 "${SIGNING_KEY}" "${SIGNING_CERT}" "${raw}" || return 1
            xz -z -q "${raw}"
            ;;
        *.ko.zst)
            zstd -d -q --rm "${mod}"
            raw="${mod%.zst}"
            "${SIGN_FILE}" sha256 "${SIGNING_KEY}" "${SIGNING_CERT}" "${raw}" || return 1
            zstd -q "${raw}"
            ;;
        *.ko.gz)
            gunzip -q "${mod}"
            raw="${mod%.gz}"
            "${SIGN_FILE}" sha256 "${SIGNING_KEY}" "${SIGNING_CERT}" "${raw}" || return 1
            gzip -q "${raw}"
            ;;
        esac
    done < <(find "${MODULE_ROOT}" -type f \( -name "*.ko" -o -name "*.ko.xz" -o -name "*.ko.zst" -o -name "*.ko.gz" \) -print0)
}

create_mok_enroll_unit() {
    local UNIT_NAME="mok-enroll.service"
    local UNIT_FILE="/usr/lib/systemd/system/${UNIT_NAME}"
    local MOK_CERT="/usr/share/cert/MOK.der"
    local TMP_DER

    TMP_DER="$(mktemp)"

    openssl x509 \
        -in "${SIGNING_CERT}" \
        -outform DER \
        -out "${TMP_DER}" || {
            rm -f "${TMP_DER}"
            return 1
        }
    install -D -m 0644 "${TMP_DER}" "${MOK_CERT}"
    rm -f "${TMP_DER}"

    install -D -m 0644 /dev/stdin "${UNIT_FILE}" <<EOF
[Unit]
Description=Enroll MOK key on first boot
ConditionPathExists=${MOK_CERT}
ConditionPathExists=!/var/.mok-enrolled

[Service]
Type=oneshot
ExecStart=/bin/sh -c '(echo "${MOK_PASSWORD}"; echo "${MOK_PASSWORD}") | mokutil --import "${MOK_CERT}"'
ExecStartPost=/usr/bin/touch /var/.mok-enrolled
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

    systemctl -f enable "${UNIT_NAME}"
    log "Created and enabled ${UNIT_NAME}"
}

if [[ ${SECURE_BOOT} == true ]]; then
    log "Signing the kernel."
    sign_kernel || exit 1
    
    log "Signing kernel modules."
    sign_kernel_modules || exit 1

    log "Creating MOK enroll unit for first boot."
    create_mok_enroll_unit  || exit 1
fi

# Initramfs
if [[ ${INITRAMFS} == true ]]; then
    log "Generating initramfs."
    TMP_INITRAMFS="$(mktemp)"
    DRACUT_NO_XATTR=1 /usr/bin/dracut \
        --no-hostonly \
        --kver "${KERNEL_VERSION}" \
        --reproducible \
        --add ostree \
        -f "${TMP_INITRAMFS}" \
        -v || return 1

    install -D -m 0600 "${TMP_INITRAMFS}" "/lib/modules/${KERNEL_VERSION}/initramfs.img"
    rm -f "${TMP_INITRAMFS}"
fi

# Final checks to eliminate having a broken build
if [[ ${SECURE_BOOT} == true ]]; then
    sha256sum -c /tmp/vmlinuz.sha || { error "Kernel modified after signing."; exit 1; }
    rm -f /tmp/vmlinux.sha
    log "Kernel was not modified after signing."
fi

if [[ ${NVIDIA} == true ]]; then
    DIR="/usr/lib/modules/${KERNEL_VERSION}/extra/nvidia"

    [[ -d "${DIR}" ]] || { error "Missing Nvidia module directory: ${DIR}"; exit 1; }

    for name in nvidia nvidia-{drm,modeset,peermem,uvm}; do
        if ! compgen -G "${DIR}/${name}.*" > /dev/null; then
            error "Missing Nvidia module: ${DIR}/${name}.*"
            exit 1
        fi
    done

    log "All Nvidia modules present."
fi

log "Custom kernel installation complete."