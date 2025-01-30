import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/gschema-overrides-v1.json")
@jsonSchema("/modules/gschema-overrides-latest.json")
model GschemaOverridesModule {
  /** The gschema-overrides module can be used for including system-setting overrides for GTK-based desktop environments.
   * https://blue-build.org/reference/modules/gschema-overrides/
   */
  type: "gschema-overrides" | "gschema-overrides@v1" | "gschema-overrides@latest";

  /** Gschema override files to test and copy to the correct place. */
  include?: Array<string>;
}
