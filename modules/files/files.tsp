import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/files-v1.json")
@jsonSchema("/modules/files-latest.json")
model FilesModule {
  /** Copy files to your image at build time
   * https://blue-build.org/reference/modules/files/
   */
  type: "files" | "files@v1" | "files@latest";

  /** List of files / folders to copy. */
  files: Array<Record<string>> | Array<{
    source: string;
    destination: string;
  }>;
}
