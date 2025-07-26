import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/default-flatpaks.json")
@oneOf
union DefaultFlatpaksModule {
    DefaultFlatpaksV1;
    DefaultFlatpaksV2;
}

@jsonSchema("/modules/default-flatpaks-latest.json")
model DefaultFlatpaksModuleLatest {
  ...DefaultFlatpaksV2;
}

@jsonSchema("/modules/default-flatpaks-v1.json")
model DefaultFlatpaksV1 {
  /** The default-flatpaks module can be used to install or uninstall flatpaks from a configurable remote on every boot.
   * using version: v1
   * https://blue-build.org/reference/modules/default-flatpaks/
   */
  type: "default-flatpaks@v1" | "default-flatpaks";

  /** Whether to send a notification after the install/uninstall is finished. */
  notify?: boolean = false;

  /** Configuration for system flatpaks. */
  system?: {
    /** URL of the repo to add. Defaults to Flathub's URL. */
    `repo-url`?: string = "https://dl.flathub.org/repo/flathub.flatpakrepo";

    /** Name for the repo to add. */
    `repo-name`?: string = "flathub";

    /** Pretty title for the repo to add. Not set by default. */
    `repo-title`?: string;

    /** List of Flatpak IDs to install from the repo. */
    install?: Array<string>;

    /** List of Flatpak IDs to remove. */
    remove?: Array<string>;
  };

  /** Configuration for user flatpaks. */
  user?: {
    /** URL of the repo to add. Defaults to Flathub's URL. */
    `repo-url`?: string = "https://dl.flathub.org/repo/flathub.flatpakrepo";

    /** Name for the repo to add. */
    `repo-name`?: string = "flathub";

    /** Pretty title for the repo to add. Not set by default. */
    `repo-title`?: string;

    /** List of Flatpak IDs to install from the repo. */
    install?: Array<string>;

    /** List of Flatpak IDs to remove. */
    remove?: Array<string>;
  };
}

@jsonSchema("/modules/default-flatpaks-v2.json")
model DefaultFlatpaksV2 {
    /** The default-flatpaks module can be used to install Flatpaks from a configurable remote on every boot.
     * using version: v2
     * https://blue-build.org/reference/modules/default-flatpaks/
     */
    type: "default-flatpaks@v2" | "default-flatpaks@latest" | "default-flatpaks";

    configurations: Array<{
        /** Whether to notify users about Flatpak installation. */
        notify?: boolean = true;

        /** Whether to perform this configuration for system-wide or separately for each user. */
        scope?: "system" | "user" = "user";

        /** Details of the Flatpak repository to set up. If omitted, Flathub will be used by default. */
        repo?: {
            /** Flatpak repository URL. */
            url?: string = "https://dl.flathub.org/repo/flathub.flatpakrepo";

            /** Flatpak repository name. */
            name?: string = "flathub";

            /** Flatpak repository formatted title. */
            title?: string = "Flathub";
        };

        /** List of Flatpak IDs to install from the repo. */
        install?: Array<string>;
    }>;
}
