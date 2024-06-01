import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/yafti.json")
model YaftiModule {
    type: "yafti",
    "custom-flatpaks"?: Array<Record<string>>
}