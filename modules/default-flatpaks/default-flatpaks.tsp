import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/default-flatpaks.json")
model DefaultFlatpaksModule {
    type: "default-flatpsk",
    notify?: boolean,
    system?: {
        "repo-url"?: string,
        "repo-name"?: string,
        "repo-title"?: string,
        install?: Array<string>,
        remove?: Array<String>,
    },
    user?: {
        "repo-url"?: string,
        "repo-name"?: string,
        "repo-title"?: string,
        install?: Array<string>,
        remove?: Array<String>,
    }
}