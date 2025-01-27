import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/initramfs-v1.json")
@jsonSchema("/modules/initramfs-latest.json")
model InitramfsModule {
  /** The initramfs module is used to regenerate initramfs, needed to apply some modifications early in the Linux startup process.
   * https://blue-build.org/reference/modules/initramfs/
   */
  type: "initramfs" | "initramfs@v1" | "initramfs@latest";
}
