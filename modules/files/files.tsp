import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/files.json")
model FilesModule {
    /** Copy files to your image at build time
     * https://blue-build.org/reference/modules/files/
     */
    type: "files";

    /** List of files / folders to copy. */
    files: Array<Record<string>>;
}
