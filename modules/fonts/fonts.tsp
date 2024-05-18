import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/fonts.json")
model FontsModule {
    type: "fonts",
    fonts: {
        "nerd-fonts": Array<string>,
        "google-fonts": Array<string>
    }
}