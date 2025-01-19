import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/files.json")
union FilesModule {
  FilesV1,
  FilesV2,
}

model FilesV1 {
  /** Copy files to your image at build time
   * https://blue-build.org/reference/modules/files/
   */
  type: "files@v1";

  /** List of files / folders to copy. */
  files: Array<Record<string>> | Array<{
    source: string;
    destination: string;
  }>;
}

model FilesV2 {
  /** Copy files to your image at build time
   * https://blue-build.org/reference/modules/files/
   */
  type: "files@v2" | "files@latest" | "files";

  /** List of files / folders to copy. */
  files: Array<{
    source: string;
    destination: string;
  }>;
}
