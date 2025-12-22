import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/zypper-latest.json")
model ZypperModuleLatest {
  ...ZypperModuleV1;
}

@jsonSchema("/modules/zypper-v1.json")
model ZypperModuleV1 {
  /**
   * The zypper module offers pseudo-declarative package and repository management using zypper.
   * https://blue-build.org/reference/modules/zypper/
   */
  type: "zypper" | "zypper@v1" | "zypper@latest";

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
