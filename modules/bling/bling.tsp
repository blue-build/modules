import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/bling.json")
model BlingModule {
    /** The bling module can be used to pull in small "bling" into your image. 
     * https://blue-build.org/reference/modules/bling/
    */
    type: "bling";

    /** List of bling submodules to run / things to install onto your system. */
    install: Array<"ublue-update" | "1password" | "dconf-update-service" | "gnome-vrr" | "laptop">;
}