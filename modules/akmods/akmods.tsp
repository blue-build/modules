import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/akmods-latest.json")
model AkmodsModuleLatest {
  ...AkmodsModuleV1;
}

@jsonSchema("/modules/akmods-v1.json")
model AkmodsModuleV1 {
  /** The akmods module is a tool used for managing and installing kernel modules built by Universal Blue.
   * https://blue-build.org/reference/modules/akmods/
   */
  type: "akmods" | "akmods@v1" | "akmods@latest";

  /** The kernel your images uses.
   * - main: stock Fedora kernel / main and nvidia images
   * - asus: asus kernel / asus images
   * - fsync: fsync kernel / not used in any Universal Blue images
   * - fsync-ba: fsync kernel, stable version / not used in any Universal Blue images
   * - surface: surface kernel / surface images
   * - coreos-stable: stock CoreOS kernel / uCore stable images
   * - coreos-testing: stock CoreOS Testing kernel / uCore testing images
   * - bazzite: Bazzite's kernel / bazzite images
   */
  base?:
    | "main"
    | "asus"
    | "fsync"
    | "fsync-ba"
    | "surface"
    | "coreos-stable"
    | "coreos-testing"
    | "bazzite" = "main";

  /** List of akmods to install.
   * See all available akmods here: https://github.com/ublue-os/akmods#kmod-packages
   */
  install: Array<string>;
}
