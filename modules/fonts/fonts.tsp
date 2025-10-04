import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/fonts-latest.json")
model FontsModuleLatest {
  ...FontsModuleV1;
}

@jsonSchema("/modules/fonts-v1.json")
model FontsModuleV1 {
  /** The fonts module can be used to install fonts from Nerd Fonts, Google Fonts, or custom URLs.
   * https://blue-build.org/reference/modules/fonts/
   */
  type: "fonts" | "fonts@v1" | "fonts@latest";

  fonts: {
    /** List of Nerd Fonts to install (without the "Nerd Font" suffix). */
    `nerd-fonts`?: Array<string>;

    /** List of Google Fonts to install. */
    `google-fonts`?: Array<string>;

    /** List of custom URL fonts to install. */
    `url-fonts`?: Array<UrlFont>;
  };
}

model UrlFont {
  /** Name for the font (will be used as directory name). */
  name: string;

  /** URL to download the font from (supports .otf, .ttf files and archives). */
  url: string;
}
