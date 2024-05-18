import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/akmods.json")
model AkmodsModule {
    type: "akmods",
    base: "main" | "asus" | "fsync" | "surface",
    install: Array<string>
}