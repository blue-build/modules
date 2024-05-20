import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/gnome-extensions.json")
model GnomeExtensionsModule {
    type: "gnome-extensions",
    install: Array<string>,
}
