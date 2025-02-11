import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/bling-latest.json")
model BlingModuleLatest {
  ...BlingModuleV1;
}

@jsonSchema("/modules/bling-v1.json")
model BlingModuleV1 {
  /** The bling module can be used to pull in small "bling" into your image.
   * https://blue-build.org/reference/modules/bling/
   */
  type: "bling" | "bling@v1" | "bling@latest";

  /** List of bling submodules to run / things to install onto your system. */
  install: Array<
    | "rpmfusion"
    | "negativo17"
    | "ublue-update"
    | "1password"
    | "dconf-update-service"
    | "gnome-vrr">;
}
