import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/custom-kernel-latest.json")
model CustomKernelModuleLatest {
  ...CustomKernelModuleV1;
}

@jsonSchema("/modules/custom-kernel-v1.json")
model CustomKernelModuleV1 {
  /**
   * A module to install custom kernels and optionally the NVIDIA driver.
   * Currently only CachyOS kernel variants are supported.
   * https://blue-build.org/reference/modules/custom-kernel/
   */
  type: "custom-kernel";

  /**
   * Kernel variant to install.
   * Currently only CachyOS kernels are supported.
   *
   * @default "cachyos-lto"
   */
  kernel?: "cachyos-lto";

  /**
   * Whether to generate an initramfs for the installed kernel.
   *
   * @default false
   */
  initramfs?: boolean;

  /**
   * Whether to install and build the NVIDIA driver for this kernel.
   *
   * @default false
   */
  nvidia?: boolean;

  /**
   * Kernel and module signing configuration.
   *
   * If this object is defined, **all fields inside it must be provided**.
   * Either define the full signing configuration or omit this entirely.
   */
  sign?: KernelSigningConfigV1;
}

/**
 * Configuration for Secure Boot kernel and module signing.
 *
 * All properties are required if this object is present.
 */
model KernelSigningConfigV1 {
  /**
   * Path to the private key used for signing.
   */
  key: string;

  /**
   * Path to the public certificate in PEM format.
   */
  cert: string;

  /**
   * Password used for MOK enrollment.
   */
  "mok-password": string;
}