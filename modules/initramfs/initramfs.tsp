import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/initramfs.json")
model InitramfsModule {
    /** The initramfs module is used to regenerate initramfs, needed to apply some modifications early in the Linux startup process.
     * https://blue-build.org/reference/modules/initramfs/
     */    
    type: "initramfs";
}
