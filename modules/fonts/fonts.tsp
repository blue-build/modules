import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/fonts-v1.json")
@jsonSchema("/modules/fonts-latest.json")
model FontsModule {
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
