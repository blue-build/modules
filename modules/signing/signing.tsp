import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/signing-v1.json")
@jsonSchema("/modules/signing-latest.json")
model SigningModule {
  /** The signing module is used to install the required signing policies for cosign image verification with rpm-ostree and bootc.
   * https://blue-build.org/reference/modules/signing/
   */
  type: "signing" | "signing@v1" | "signing@latest";
}
