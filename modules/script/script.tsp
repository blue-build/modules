import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/script-latest.json")
@extension("additionalProperties", false)
model ScriptModuleLatest {
  ...ScriptModuleV1;
}

@jsonSchema("/modules/script-v2.json")
@extension("additionalProperties", false)
model ScriptModuleV2 {
  /** The script module can be used to run arbitrary posix shell snippets and scripts at image build time.
   * https://blue-build.org/reference/modules/script/
   */
  @oneOf
  type: "script" | "script@v2" | "script@latest";

  /** List of bash one-liners to run. */
  snippets?: Array<string>;

  /** List of script files to run. */
  scripts?: Array<string>;
}

@jsonSchema("/modules/script-v1.json")
@extension("additionalProperties", false)
model ScriptModuleV1 {
  /** The script module can be used to run arbitrary bash snippets and scripts at image build time.
   * https://blue-build.org/reference/modules/script/
   */
  type: "script@v1";

  /** List of bash one-liners to run. */
  snippets?: Array<string>;

  /** List of script files to run. */
  scripts?: Array<string>;
}
