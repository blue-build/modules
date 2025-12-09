import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/signing-latest.json")
@extension("additionalProperties", false)
model SigningModuleLatest {
  ...SigningModuleV1;
}

@jsonSchema("/modules/signing-v1.json")
@extension("additionalProperties", false)
model SigningModuleV1 {
  /** The signing module is used to install the required signing policies for cosign image verification with rpm-ostree and bootc.
   * https://blue-build.org/reference/modules/signing/
   */
  type: "signing" | "signing@v1" | "signing@latest";
}
