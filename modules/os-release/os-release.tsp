import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/os-release-latest.json")
model OsReleaseLatest {
  ...OsReleaseV1;
}

@jsonSchema("/modules/os-release-v1.json")
model OsReleaseV1 {
  /** The properties of the `/etc/os-release` file to set. */
  properties: Record<string>;
}
