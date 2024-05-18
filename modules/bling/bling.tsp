import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/bling.json")
model BlingModule {
    type: "bling",
    install: "ublue-update" | "1password" | "dconf-update-service" | "gnome-vrr" | "laptop" | "flatpaksync"
}