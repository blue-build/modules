import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/files.json")
model FilesModule {
    type: "files",
    files: Array<object>
}