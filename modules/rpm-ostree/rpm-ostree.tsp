import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/rpm-ostree-latest.json")
model RpmOstreeModuleLatest {
  ...RpmOstreeModuleV1;
}

@jsonSchema("/modules/rpm-ostree-v1.json")
model RpmOstreeModuleV1 {
  /** The rpm-ostree module offers pseudo-declarative package and repository management using rpm-ostree.
   * https://blue-build.org/reference/modules/rpm-ostree/
   */
  type: "rpm-ostree" | "rpm-ostree@v1" | "rpm-ostree@latest";

  /** List of links to .repo files to download into /etc/yum.repos.d/. */
  repos?: Array<string>;

  /** List of links to key files to import for installing from custom repositories. */
  keys?: Array<string>;

  /** List of folder names under /opt/ to enable for installing into. */
  optfix?: Array<string>;

  /** List of RPM packages to install. */
  install?: Array<string>;

  /** List of RPM packages to remove. */
  remove?: Array<string>;

  /** List of configurations for `rpm-ostree override replace`ing packages. */
  replace?: Array<{
    /** URL to the source COPR repo for the new packages. */
    `from-repo`: string;

    /** List of packages to replace using packages from the defined repo. */
    packages: Array<string>;
  }>;
}
