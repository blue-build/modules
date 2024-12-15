import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/initramfs.json")
model InitramfsModule {
    /** The initramfs module is used to regenerate initramfs, needed for some modifications in early Linux startup process to apply.
     * https://blue-build.org/reference/modules/initramfs/
     */    
    type: "initramfs";
}
