import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/quadlets-latest.json")
model QuadletsModuleLatest {
  ...QuadletsModuleV1;
}

@jsonSchema("/modules/quadlets-v1.json")
model QuadletsModuleV1 {
  /** The quadlets module manages Podman Quadlet deployments with automatic updates and systemd integration.
   * https://blue-build.org/reference/modules/quadlets/
   */
  type: "quadlets" | "quadlets@v1" | "quadlets@latest";

  /** List of quadlet configurations to install and manage. */
  configurations: Array<{
    /** Unique identifier for this quadlet. Must match the directory name. */
    name: string;

    /** Source location for the quadlet files.
     * Can be a Git URL (https://github.com/org/repo/tree/branch/path) or local path (~/.config/containers/systemd/name).
     */
    source: string;

    /** Scope of installation: 'user' for per-user services, 'system' for system-wide services. */
    scope?: "user" | "system" = "user";

    /** Git branch to use when source is a Git URL. */
    branch?: string = "main";

    /** Whether to send desktop notifications for this quadlet's operations. */
    notify?: boolean = true;

    /** If true, this quadlet is managed externally (e.g., by chezmoi) and the module will only discover it.
     * The module will not copy files but will track and manage systemd integration.
     */
    `managed-externally`?: boolean = false;

    /** Delay before attempting to discover/setup this quadlet after boot.
     * Useful for externally-managed quadlets that require manual steps (e.g., decrypting secrets).
     * Time format: systemd time span (e.g., '5m', '10min', '1h').
     */
    `setup-delay`?: string = "5m";
  }>;

  /** Configuration for automatic updates of quadlet definitions from Git sources. */
  `auto-update`?: {
    /** Whether to enable automatic updates of quadlet definitions. */
    enabled?: boolean = true;

    /** How often to check for updates. Time format: systemd time span (e.g., '1d', '7d', '1w'). */
    interval?: string = "7d";

    /** Delay after system boot before first update check. Time format: systemd time span. */
    `wait-after-boot`?: string = "5m";
  };

  /** Configuration for automatic updates of container images via Podman's auto-update feature. */
  `container-auto-update`?: {
    /** Whether to enable Podman's automatic container image updates. */
    enabled?: boolean = true;

    /** How often to check for container image updates. */
    interval?: "daily" | "weekly" | "monthly" = "daily";
  };
}
