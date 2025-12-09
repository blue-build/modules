import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/yafti-latest.json")
@extension("additionalProperties", false)
model YaftiModuleLatest {
  ...YaftiModuleV1;
}

@jsonSchema("/modules/yafti-v1.json")
@extension("additionalProperties", false)
model YaftiModuleV1 {
  /** The yafti module can be used to install yafti and set it up to run on first boot.
   * https://blue-build.org/reference/modules/yafti/
   */
  type: "yafti" | "yafti@v1" | "yafti@latest";

  /** List of custom Flatpaks to inject to the default yafti.yml. Format is: `PrettyName: org.example.flatpak_id` */
  `custom-flatpaks`?: Array<Record<string>>;
}
