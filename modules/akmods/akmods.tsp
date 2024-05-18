import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/akmods.json")
model akmodsModule {
    type: "akmods",
    base: "main" | "asus" | "fsync" | "surface",
    install: Array<string>
}