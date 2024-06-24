import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/brew.json")
model BrewModule {
    /** The brew module installs Homebrew / Linuxbrew at build time and ensures the package manager remains up-to-date.
     * https://blue-build.org/reference/modules/brew/
    */
    type: "brew",

    /** Whether to auto-update the Brew binary. (default: true) */
    "auto-update"?: boolean,

    /** Interval between Brew updates. (default: 6h) */
    "update-interval"?: string,

    /** Time delay after boot before first Brew update. (default: 10min) */
    "update-wait-after-boot"?: string, 

    /** Wthether to auto-upgrade Brew packages. (default: true) */
    "auto-upgrade"?: boolean,

    /** Interval between Brew package upgrades. (default: 8h) */
    "upgrade-interval"?: string,

    /** Time delay after boot before first Brew package upgrade. (default: 30min) */
    "upgrade-wait-after-boot"?: string,

    /** Whether to apply nofile limits (limits for number of open files) for Brew installations. (default: false) */
    "nofile-limits"?: boolean,

    /** Whether to enable Brew analytics. (default: true) */
    "brew-analytics"?: boolean,
}