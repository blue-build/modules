import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/gnome-extensions.json")
model GnomeExtensionsModule {
    /** The gnome-extensions module can be used to install GNOME extensions inside system directory.
     * https://blue-build.org/reference/modules/gnome-extensions/
     */
    type: "gnome-extensions";

    /** List of GNOME extensions to install. 
     * (case sensitive extension names or extension IDs from https://extensions.gnome.org/)
    */
    install?: Array<string>;

    /** List of system GNOME extensions to uninstall. 
     * Only use this to remove extensions not installed by your package manager. Those extensions should be uninstalled using the package manager instead.
    */
    uninstall?: Array<string>;
}
