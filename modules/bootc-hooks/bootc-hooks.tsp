import "@typespec/json-schema";
using TypeSpec.JsonSchema;

model HookEvents {
  /** Actions to run on boot. */
  boot?: string[];
  /** Actions to run on OS update. */
  update?: string[];
  /** Actions to run on OS switch (rollback). */
  switch?: string[];
}

@jsonSchema("/modules/bootc-hooks-latest.json")
model BootcHooksModuleLatest {
  ...BootcHooksModuleV1
}
@jsonSchema("/modules/bootc-hooks-v1.json")
model BootcHooksModuleV1 {
  /**
   * The bootc-hooks module adds a service that runs scripts based on bootc events.
   */
  type: "bootc-hooks" | "bootc-hooks@v1" | "bootc-hooks@latest";
  /** Hooks to run in the system context. */
  system?: HookEvents;
  /** Hooks to run in the user context. */
  user?: HookEvents;
}
