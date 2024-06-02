import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/chezmoi.json")
model ChezmoiModule {
    /** The chezmoi module installs the latest chezmoi release at build time, along with services to clone a dotfile repository and keep it up-to-date.
     * https://blue-build.org/reference/modules/chezmoi/
    */
    type: "chezmoi",

    /** Git repository to initialize. */
    repository: string,

    /** Whether to enable the modules services globally for all users, if false users need to enable services manually. (default: true) */
    "all-users"?: boolean,

    /** Dotfiles will be updated with this interval. (default: 1d) */
    "run-every"?: string,

    /** Dotfile updates will wait this long after a boot before running. (default: 5m)*/
    "wait-after-boot"?: string,
    
    /** Disable the service that initializes `repository` on users that are logged in or have linger enabled UI. (default: false) */
    "disable-init"?: boolean,

    /** Disable the timer that updates chezmoi with the set interval. (default: false) */
    "disable-update"?: boolean,

    /** What to do when file different that exists on your repo is has been changed or exists locally. Accepts "skip" or "replace". (default: skip) */
    "file-conflict-policy"?: "skip" | "replace"
}