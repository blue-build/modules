import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/signing.json")
model SigningModule {
    type: "signing",
}