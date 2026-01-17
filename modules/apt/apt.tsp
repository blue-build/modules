import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/apt-latest.json")
model AptModuleLatest {
  ...AptModuleV1;
}

@jsonSchema("/modules/apt-v1.json")
model AptModuleV1 {
  /**
   * The apt module offers pseudo-declarative package and repository management using apt.
   * https://blue-build.org/reference/modules/apt/
   */
  type: "apt" | "apt@v1" | "apt@latest";

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
