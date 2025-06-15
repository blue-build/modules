import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/fonts-latest.json")
model FontsModuleLatest {
  ...FontsModuleV1;
}

@jsonSchema("/modules/fonts-v1.json")
model FontsModuleV1 {
  /** The fonts module can be used to install fonts from Nerd Fonts or Google Fonts.
   * https://blue-build.org/reference/modules/fonts/
   */
  type: "fonts" | "fonts@v1" | "fonts@latest";

  fonts: {
    /** List of Nerd Fonts to install (without the "Nerd Font" suffix). */
    `nerd-fonts`?: Array<string>;

    /** List of Google Fonts to install. */
    `google-fonts`?: Array<string>;
  };
}
