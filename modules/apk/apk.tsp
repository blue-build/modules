import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/apk-latest.json")
model ApkModuleLatest {
  ...ApkModuleV1;
}

@jsonSchema("/modules/apk-v1.json")
model ApkModuleV1 {
  /**
   * The apk module offers pseudo-declarative package and repository management using apk.
   * https://blue-build.org/reference/modules/apk/
   */
  type: "apk" | "apk@v1" | "apk@latest";

  /** Configuration of packages removal. */
  remove?: ApkRemove;

  /** Configuration of packages install. */
  install?: ApkInstall;
}

model ApkInstall {
  /** List of packages to install. */
  packages: Array<string>;
}

model ApkRemove {
  /** List of packages to remove. */
  packages: Array<string>;
}
