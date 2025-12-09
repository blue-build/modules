import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@extension("additionalProperties", false)
@jsonSchema("/modules/files-latest.json")
model FilesModuleLatest {
  ...FilesModuleV1;
}

@extension("additionalProperties", false)
@jsonSchema("/modules/files-v1.json")
model FilesModuleV1 {
  /** Copy files to your image at build time
   * https://blue-build.org/reference/modules/files/
   */
  type: "files" | "files@v1" | "files@latest";

  /** List of files / folders to copy. */
  @oneOf
  files: Array<Record<string>> | Array<SrcDest>;
}

@extension("additionalProperties", false)
model SrcDest {
  source: string;
  destination: string;
}
