import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/files.json")
@oneOf
union FilesModule {
  FilesModuleV1,
  FilesModuleV2,
}

@jsonSchema("/modules/files-latest.json")
model FilesModuleLatest {
  ...FilesModuleV1;
}

@jsonSchema("/modules/files-v1.json")
model FilesModuleV1 {
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

model FilesModuleV2 {
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
