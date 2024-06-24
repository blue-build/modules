import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/default-flatpaks.json")
model DefaultFlatpaksModule {
    /** The default-flatpaks module can be used to install or uninstall flatpaks from a configurable remote on every boot.
     * https://blue-build.org/reference/modules/default-flatpaks/
    */
    type: "default-flatpaks",

    /** Whether to send a notification after the install/uninstall is finished. */
    notify?: boolean = false,

    /** Configuration for system flatpaks. */
    system?: {
        /** URL of the repo to add. Defaults to Flathub's URL. */
        "repo-url"?: string = "https://dl.flathub.org/repo/flathub.flatpakrepo",

        /** Name for the repo to add. */
        "repo-name"?: string = "flathub",

        /** Pretty title for the repo to add. Not set by default. */
        "repo-title"?: string,

        /** List of Flatpak IDs to install from the repo. */
        install?: Array<string>,

        /** List of Flatpak IDs to remove. */
        remove?: Array<string>,
    },

    /** Configuration for user flatpaks. */
    user?: {
        /** URL of the repo to add. Defaults to Flathub's URL. */
        "repo-url"?: string = "https://dl.flathub.org/repo/flathub.flatpakrepo",

        /** Name for the repo to add. */
        "repo-name"?: string = "flathub",

        /** Pretty title for the repo to add. Not set by default. */
        "repo-title"?: string,

        /** List of Flatpak IDs to install from the repo. */
        install?: Array<string>,

        /** List of Flatpak IDs to remove. */
        remove?: Array<string>,
    }
}