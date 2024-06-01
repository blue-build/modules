import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/systemd.json")
model SystemdModule {
    type: "systemd",
    system?: {
        enabled?: Array<string>,
        disabled?: Array<string>,
        masked?: Array<string>,
        unmasked?: Array<string>
    },
    user?: {
        enabled?: Array<string>,
        disabled?: Array<string>,
        masked?: Array<string>,
        unmasked?: Array<string>
    }
}