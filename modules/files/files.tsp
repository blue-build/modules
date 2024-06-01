import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/files.json")
model FilesModule {
    /** Copy files to your image at build time */
    type: "files",

    /** List of files / folders to copy. Format is: `sourcefile.txt: /destination/file.txt`  */
    files: Array<Record<string>>
}