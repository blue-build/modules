import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/gschema-overrides-latest.json")
model GschemaOverridesModuleLatest {
  ...GschemaOverridesModuleV1;
}

@jsonSchema("/modules/gschema-overrides-v1.json")
model GschemaOverridesModuleV1 {
  /** The gschema-overrides module can be used for including system-setting overrides for GTK-based desktop environments.
   * https://blue-build.org/reference/modules/gschema-overrides/
   */
  type: "gschema-overrides" | "gschema-overrides@v1" | "gschema-overrides@latest";

  /** Gschema override files to test and copy to the correct place. */
  include?: Array<string>;
}
