import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/akmods.json")
model AkmodsModule {
    /** The akmods module is a tool used for managing and installing kernel modules built by Universal Blue.
     * https://blue-build.org/reference/modules/akmods/
     */
    type: "akmods";

    /** The kernel your images uses.
     * - main: stock kernel / main and nvidia images
     * - asus: asus kernel / asus images
     * - fsync: fsync kernel / bazzite images
     * - surface: surface kernel / surface images
     */
    base?: "main" | "asus" | "fsync" | "surface" = "main";

    /** List of akmods to install.
     * See all available akmods here: https://github.com/ublue-os/akmods#kmod-packages
     */
    install: Array<string>;
}