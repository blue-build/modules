import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/os-release-latest.json")
model OsReleaseLatest {
  ...OsReleaseV1;
}

@jsonSchema("/modules/os-release-v1.json")
model OsReleaseV1 {
  /** The `os-release` module offers a way to modify and set values in the `/etc/os-release` file in your image.
   * https://blue-build.org/reference/modules/os-release/
   */
  type: "os-release" | "os-release@v1" | "os-release@latest";

  /** The properties of the `/etc/os-release` file to set. */
  properties: Record<string>;
}
