import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@extension("additionalProperties", false)
@jsonSchema("/modules/signing-latest.json")
model SigningModuleLatest {
  ...SigningModuleV1;
}

@extension("additionalProperties", false)
@jsonSchema("/modules/signing-v1.json")
model SigningModuleV1 {
  /** The signing module is used to install the required signing policies for cosign image verification with rpm-ostree and bootc.
   * https://blue-build.org/reference/modules/signing/
   */
  type: "signing" | "signing@v1" | "signing@latest";
}
