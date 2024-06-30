import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/brew.json")
model BrewModule {
    /** The brew module installs Homebrew / Linuxbrew at build time and ensures the package manager remains up-to-date.
     * https://blue-build.org/reference/modules/brew/
    */
    type: "brew";

    /** Whether to auto-update the Brew binary. */
    "auto-update"?: boolean = true;

    /** Interval between Brew updates. */
    "update-interval"?: string = "6h";

    /** Time delay after boot before first Brew update .*/
    "update-wait-after-boot"?: string = "10min";

    /** Wthether to auto-upgrade Brew packages. */
    "auto-upgrade"?: boolean = true;

    /** Interval between Brew package upgrades. */
    "upgrade-interval"?: string = "8h";

    /** Time delay after boot before first Brew package upgrade. */
    "upgrade-wait-after-boot"?: string = "30min";

    /** Whether to apply nofile limits (limits for number of open files) for Brew installations. */
    "nofile-limits"?: boolean = false;

    /** Whether to enable Brew analytics. */
    "brew-analytics"?: boolean = true;
}