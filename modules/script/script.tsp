import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/script.json")
model ScriptModule {
    /** The script module can be used to run arbitrary bash snippets and scripts at image build time.
     * https://blue-build.org/reference/modules/script/
     */
    type: "script";

    /** List of bash one-liners to run. */
    snippets?: Array<string>;

    /** List of script files to run. */
    scripts?: Array<string>;
}