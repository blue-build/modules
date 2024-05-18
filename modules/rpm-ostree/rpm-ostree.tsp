import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/rpm-ostree.json")
model RpmOstreeModule {
    type: "rpm-ostree",
    repos?: Array<string>,
    install?: Array<string>,
    remove?: Array<string>,
}