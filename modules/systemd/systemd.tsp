import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/systemd-latest.json")
@extension("additionalProperties", false)
model SystemdModuleLatest {
  ...SystemdModuleV1;
}

@jsonSchema("/modules/systemd-v1.json")
@extension("additionalProperties", false)
model SystemdModuleV1 {
  /** The systemd module streamlines the management of systemd units during image building.
   * https://blue-build.org/reference/modules/systemd/
   */
  type: "systemd" | "systemd@v1" | "systemd@latest";

  /** System unit configuration. */
  system?: UnitConfig;

  /** User unit configuration (with --global to make changes for all users). */
  user?: UnitConfig;
}

@extension("additionalProperties", false)
model UnitConfig {
  /** List of systemd units to enable. (runs on system boot) */
  enabled?: Array<string>;

  /** List of systemd units to disable. (does not run on system boot, unless another unit strictly requires it) */
  disabled?: Array<string>;

  /** List of systemd units to mask. (does not run on system boot, under any circumstances) */
  masked?: Array<string>;

  /** List of systemd units to unmask. (runs on system boot, even if previously masked) */
  unmasked?: Array<string>;
}
