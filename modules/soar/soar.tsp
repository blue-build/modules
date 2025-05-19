import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/soar-latest.json")
model SoarModuleLatest {
  ...SoarModuleV1;
}

@jsonSchema("/modules/soar-v1.json")
model SoarModuleV1 {
  /** The soar module installs & integrates soar package manager, as an alternative to Homebrew / Linuxbrew.
   * https://blue-build.org/reference/modules/soar/
   */
  type: "soar" | "soar@v1" | "soar@latest";

  /** Whether to auto-upgrade all installed `sour` packages using a systemd service. */
  `auto-upgrade`?: boolean = true;

  /** Defines how often the `soar` upgrade service should run. The string is passed directly to `OnUnitInactiveSec` in systemd timer. (Syntax: ['1d', '6h', '10m']). */
  `upgrade-interval`?: string = "8h";

  /** Time delay after system boot before the first `soar` package upgrade runs. The string is passed directly to `OnBootSec` in systemd timer. (Syntax: ['1d', '6h', '10m']). */
  `upgrade-wait-after-boot`?: string = "30min";

  /** Whether to unlock all official `sour` & external repos, including `pkgcache`, for installing portable AppImages & other similar formats. */
  `unlock-repos`?: boolean = false;
}
