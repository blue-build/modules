import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/kargs-latest.json")
model KargsModuleLatest {
  ...KargsModuleV1;
}

@jsonSchema("/modules/kargs-v1.json")
model KargsModuleV1 {
  /** The kargs module injects kernel arguments into the image.
   * https://blue-build.org/reference/modules/kargs/
   */
  type: "kargs" | "kargs@v1" | "kargs@latest";

  /** Defines on which OS architectures are kargs applied. Defaults to all architectures if omitted. */
  `arch`?: string;

  /** Kargs to inject in the image. */
  `kargs`: Array<string>;
}
