# custom-kernel

The custom-kernel module installs a custom Linux kernel on Fedora-based images.  
The module currently supports CachyOS kernel variants and can optionally install the NVIDIA driver and perform Secure Boot signing.

## Description

The custom-kernel module replaces or augments the default Fedora kernel with a selected CachyOS kernel variant.  
The module can generate an initramfs for the installed kernel and can build NVIDIA kernel modules that match the selected kernel version.

The custom-kernel module can optionally sign the kernel image and kernel modules for use with Secure Boot.  
When Secure Boot signing is enabled, a Machine Owner Key (MOK) is enrolled on first boot using the provided credentials.

## Configuration

The custom-kernel module is configured using the following options.

### `kernel`

The `kernel` field selects the CachyOS kernel variant to install.  
If not specified, the default value `cachyos-lto` is used.

Supported values include:

- `cachyos`
- `cachyos-lto`
- `cachyos-lts`
- `cachyos-lts-lto`
- `cachyos-rt`

### `initramfs`

The `initramfs` field controls whether an initramfs is generated for the installed kernel.  
If not specified, the default value `false` is used.

### `nvidia`

The `nvidia` field controls whether the NVIDIA driver is built and installed for the selected kernel.  
If not specified, the default value `false` is used.

### `sign`

The `sign` field enables Secure Boot signing of the kernel and kernel modules.  
The `sign` field is optional, but when it is defined, **all fields inside the object must be provided**.

When the image is booted for the first time, the provided Machine Owner Key (MOK) is **automatically enrolled** using the configured credentials.  
This enrollment is performed during early boot and requires a reboot to complete.

If Secure Boot signing is enabled, the kernel image and all kernel modules are signed during the image build process.

#### `sign.key`

The `key` field specifies the path to the private key used for signing.  
The key file must be available inside the build environment and mounted to the container (see example) during build-time.

#### `sign.cert`

The `cert` field specifies the path to the public certificate in PEM format.  
The certificate must correspond to the private signing key.

#### `sign.mok-password`

The `mok-password` field specifies the password used during MOK enrollment on first boot.

## Example

```yaml
type: custom-kernel
kernel: cachyos-lto
initramfs: true
nvidia: true
sign:
  key: /tmp/certs/MOK.key
  cert: /path/to/MOK.pem
  mok-password: BlueBuild
secrets:
  - type: file
    source: ./MOK.key
    mount:
      type: file
      destination: /tmp/certs/MOK.key