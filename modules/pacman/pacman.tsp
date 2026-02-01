import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/pacman-latest.json")
model PacmanModuleLatest {
  ...PacmanModuleV1;
}

@jsonSchema("/modules/pacman-v1.json")
model PacmanModuleV1 {
  /**
   * The pacman module offers pseudo-declarative package and repository management using pacman.
   * https://blue-build.org/reference/modules/pacman/
   */
  type: "pacman" | "pacman@v1" | "pacman@latest";

  /** Configuration of packages removal. */
  remove?: PacmanRemove;

  /** Configuration of packages install. */
  install?: PacmanInstall;
}

model PacmanInstall {
  /** List of packages to install. */
  packages: Array<string>;
}

model PacmanRemove {
  /** List of packages to remove. */
  packages: Array<string>;
}
