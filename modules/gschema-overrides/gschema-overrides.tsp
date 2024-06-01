import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/gschema-overrides.json")
model GschemaOverridesModule {
    type: "gschema-overrides",
    include: Array<string>
}