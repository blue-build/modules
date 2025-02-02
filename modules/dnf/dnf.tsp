import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/dnf-latest.json")
model DnfModuleLatest {
  ...DnfModuleV1;
}

@jsonSchema("/modules/dnf-v1.json")
model DnfModuleV1 {
  /**
   * The dnf module offers pseudo-declarative package and repository management using dnf.
   * https://blue-build.org/reference/modules/dnf/
   */
  type: "dnf" | "dnf@v1" | "dnf@latest";

  /** List of links to .repo files to download into /etc/yum.repos.d/. */
  repos?: DnfRepo;

  /** List of folder names under /opt/ to enable for installing into. */
  optfix?: Array<string>;

  /** Configuration of RPM groups removal. */
  `group-remove`?: DnfGroupRemove;

  /** Configuration of RPM groups install. */
  `group-install`?: DnfGroupInstall;

  /** Configuration of RPM packages removal. */
  remove?: DnfRemove;

  /** Configuration of RPM packages install. */
  install?: DnfInstall;

  /** List of configurations for replacing packages from another repo. */
  replace?: Array<DnfReplace>;
}

model DnfRepo {
  /** List of paths or URLs to .repo files to import */
  files?: Array<string> | DnfRepoFiles;

  /**
   * List of COPR project repos to add.
   * You can also specify 2 lists
   * instead to 'enable' or 'disable' COPR repos.
   */
  copr?: Array<string> | DnfRepoCopr;

  /** List of links to key files to import for installing from custom repositories. */
  keys?: Array<string>;
}

model DnfRepoFiles {
  /** List of repo files/URLs to add. */
  add?: Array<string>;

  /**
   * List of repos to remove.
   * This must be the ID of the repo
   * as seen in `dnf5 repolist`.
   */
  remove?: Array<string>;
}

model DnfRepoCopr {
  /** List of COPR repos to enable */
  enable?: Array<string>;

  /** List of COPR repos to disable */
  disable?: Array<string>;
}

model DnfInstall {
  /** List of RPM packages to install. */
  packages: Array<string | DnfInstallRepo>;

  /** Whether to install weak dependencies during the RPM package install or not. */
  `install-weak-dependencies`?: boolean = true;

  /** Whether to continue with the RPM package install if there are no packages available in the repository. */
  `skip-unavailable-packages`?: boolean = false;

  /** Whether to continue with the RPM package install if there are broken packages. */
  `skip-broken-packages`?: boolean = false;

  /** Whether to allow erasing (removal) of packages in case of dependency problems during the RPM package install. */
  `allow-erasing-packages`?: boolean = false;
}

model DnfInstallRepo {
  /** The repo to use when installing packages */
  repo: string;

  /** List of RPM packages to install. */
  packages: Array<string>;
}

model DnfRemove {
  /** List of RPM packages to remove. */
  packages: Array<string>;

  /** Whether to remove unused dependencies during removal operation. */
  `remove-unused-dependencies`?: boolean = true;
}

model DnfReplace {
  /** URL to the source COPR repo for the new packages. */
  `from-repo`: string;

  /** List of packages to replace using packages from the defined repo. */
  packages: Array<string>;

  /** Whether to install weak dependencies during the replacement or not. */
  `install-weak-dependencies`?: boolean = true;

  /** Whether to continue with the replacement if there are no packages available on the system to replace. */
  `skip-unavailable-packages`?: boolean = false;

  /** Whether to continue with the replacement if there are broken packages in the system during the replacement. */
  `skip-broken-packages`?: boolean = false;

  /** Whether to allow erasing (removal) of packages in case of dependency problems during the replacement. */
  `allow-erasing-packages`?: boolean = false;
}

model DnfGroupInstall {
  /** List of RPM groups to install. */
  packages: Array<string>;

  /** Whether to install weak dependencies during the RPM group install or not. */
  `install-weak-dependencies`?: boolean = true;

  /** Whether to continue with the RPM group install if there are no packages available in the repository. */
  `skip-unavailable-packages`?: boolean = false;

  /** Whether to continue with the RPM group install if there are broken packages. */
  `skip-broken-packages`?: boolean = false;

  /** Whether to allow erasing (removal) of packages in case of dependency problems during the RPM group install. */
  `allow-erasing-packages`?: boolean = false;
}

model DnfGroupRemove {
  /** List of RPM groups to remove. */
  packages: Array<string>;
}
