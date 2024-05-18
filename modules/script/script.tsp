import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/script.json")
model ScriptModule {
    type: "script",
    snippets: Array<string>,
    scripts: Array<string>,
}