import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/chezmoi-latest.json")
model ChezmoiModuleLatest {
  ...ChezmoiModuleV1;
}

@jsonSchema("/modules/chezmoi-v1.json")
model ChezmoiModuleV1 {
  /** The chezmoi module installs the latest chezmoi release at build time, along with services to clone a dotfile repository and keep it up-to-date.
   * https://blue-build.org/reference/modules/chezmoi/
   */
  type: "chezmoi" | "chezmoi@v1" | "chezmoi@latest";

  /** Git repository to initialize. */
  repository: string;

  /** Git branch of the chezmoi repository. */
  branch?: string = "";

  /** Whether to enable the modules services globally for all users, if false users need to enable services manually. */
  `all-users`?: boolean = true;

  /** Dotfiles will be updated with this interval. */
  `run-every`?: string = "1d";

  /** Dotfile updates will wait this long after a boot before running. */
  `wait-after-boot`?: string = "5m";

  /** Disable the service that initializes `repository` on users that are logged in or have linger enabled UI. */
  `disable-init`?: boolean = false;

  /** Disable the timer that updates chezmoi with the set interval. */
  `disable-update`?: boolean = false;

  /** What to do when file different that exists on your repo is has been changed or exists locally. Accepts "skip" or "replace". */
  `file-conflict-policy`?: "skip" | "replace" = "skip";
}
