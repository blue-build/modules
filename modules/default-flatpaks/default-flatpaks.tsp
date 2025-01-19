import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/default-flatpaks.json")
union DefaultFlatpaksModule {
    DefaultFlatpaksV1;
    DefaultFlatpaksV2;
}

model DefaultFlatpaksV1 {
    /** The default-flatpaks module can be used to install or uninstall flatpaks from a configurable remote on every boot.
     * https://blue-build.org/reference/modules/default-flatpaks/
     */
    type: "default-flatpaks@v1";

    /** Whether to send a notification after the install/uninstall is finished. */
    notify?: boolean = false;

    /** Configuration for system flatpaks. */
    system?: {
        /** URL of the repo to add. Defaults to Flathub's URL. */
        "repo-url"?: string = "https://dl.flathub.org/repo/flathub.flatpakrepo";

        /** Name for the repo to add. */
        "repo-name"?: string = "flathub";

        /** Pretty title for the repo to add. Not set by default. */
        "repo-title"?: string;

        /** List of Flatpak IDs to install from the repo. */
        install?: Array<string>;

        /** List of Flatpak IDs to remove. */
        remove?: Array<string>;
    };

    /** Configuration for user flatpaks. */
    user?: {
        /** URL of the repo to add. Defaults to Flathub's URL. */
        "repo-url"?: string = "https://dl.flathub.org/repo/flathub.flatpakrepo";

        /** Name for the repo to add. */
        "repo-name"?: string = "flathub";

        /** Pretty title for the repo to add. Not set by default. */
        "repo-title"?: string;

        /** List of Flatpak IDs to install from the repo. */
        install?: Array<string>;

        /** List of Flatpak IDs to remove. */
        remove?: Array<string>;
    };
}

model DefaultFlatpaksV2 {
    /** The default-flatpaks module can be used to install Flatpaks from a configurable remote on every boot.
     * https://blue-build.org/reference/modules/default-flatpaks/
     */
    type: "default-flatpaks@v2" | "default-flatpaks@latest" | "default-flatpaks";

    configurations: Array<{
        /** Whether to notify users about Flatpak installation (default: true). */
        notify?: boolean;

        /** Whether to perform this configuration for system-wide or separately for each user (default: user). */
        scope?: "system" | "user";

        /** Details of the Flatpak repository to set up. (default: flathub) */
        repo?: {
            /** Flatpak repository URL (default: https://dl.flathub.org/repo/flathub.flatpakrepo). */
            url?: string;

            /** Flatpak repository name (default: flathub). */
            name?: string;

            /** Flatpak repository formatted title (default: Flathub). */
            title?: string;
        };

        /** List of Flatpak IDs to install from the repo. */
        install?: Array<string>;
    }>;
}