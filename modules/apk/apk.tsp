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
  remove?: Remove;

  /** Configuration of packages install. */
  install?: Install;
}

model Install {
  /** List of packages to install. */
  packages: Array<string>;
}

model Remove {
  /** List of packages to remove. */
  packages: Array<string>;
}
