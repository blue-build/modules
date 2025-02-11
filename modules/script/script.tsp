import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/script-latest.json")
model ScriptModuleLatest {
  ...ScriptModuleV1;
}

@jsonSchema("/modules/script-v1.json")
model ScriptModuleV1 {
  /** The script module can be used to run arbitrary bash snippets and scripts at image build time.
   * https://blue-build.org/reference/modules/script/
   */
  type: "script" | "script@v1" | "script@latest";

  /** List of bash one-liners to run. */
  snippets?: Array<string>;

  /** List of script files to run. */
  scripts?: Array<string>;
}
