import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@extension("additionalProperties", false)
@jsonSchema("/modules/dnf-latest.json")
model DnfModuleLatest {
  ...DnfModuleV1;
}

@extension("additionalProperties", false)
@jsonSchema("/modules/dnf-v1.json")
model DnfModuleV1 {
  /**
   * The dnf module offers pseudo-declarative package and repository management using dnf.
   * https://blue-build.org/reference/modules/dnf/
   */
  type: "dnf" | "dnf@v1" | "dnf@latest";

  /** List of links to .repo files to download into /etc/yum.repos.d/. */
  repos?: DnfRepo;

  /** DEPRECATED: List of folder names under /opt/ to enable for installing into. */
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

@extension("additionalProperties", false)
model DnfRepo {
  /** Cleans up the repos added in the same step after packages are installed. */
  cleanup?: boolean = false;

  /** List of paths or URLs to .repo files to import */
  files?: Array<string> | DnfRepoFiles;

  /**
   * List of COPR project repos to add.
   * You can also specify 2 lists
   * instead to 'enable' or 'disable' COPR repos.
   */
  copr?: Array<string | DnfRepoCoprEnable> | DnfRepoCopr;

  /** List of links to key files to import for installing from custom repositories. */
  keys?: Array<string>;

  /**
   * Enable one of the nonfree repos.
   *
   * This allows you to enable one of the nonfree repos.
   * However, only one can be enabled at a time so if one
   * is enabled, the other will be disabled if it is already enabled.
   */
  nonfree?: "negativo17" | "rpmfusion";
}

@extension("additionalProperties", false)
model DnfRepoFiles {
  /** List of repo files/URLs to add. */
  add?: Array<string>;

  /**
   * List of repos to disable.
   * This must be the ID of the repo
   * as seen in `dnf5 repolist`.
   */
  remove?: Array<string>;
}

@extension("additionalProperties", false)
model DnfRepoCopr {
  /** List of COPR repos to enable */
  enable?: Array<string | DnfRepoCoprEnable>;

  /** List of COPR repos to disable */
  disable?: Array<string>;
}

@extension("additionalProperties", false)
model DnfRepoCoprEnable {
  /** The COPR repo's name */
  name: string;

  /** The chroot for the COPR repo */
  chroot: string;
}

@extension("additionalProperties", false)
model DnfInstall {
  /** List of RPM packages to install. */
  packages: Array<string | DnfInstallRepo>;

  ...DnfInstallCommon;
}

@extension("additionalProperties", false)
model DnfInstallRepo {
  /** The repo to use when installing packages */
  repo: string;

  /** List of RPM packages to install. */
  packages: Array<string>;

  ...DnfInstallCommon;
}

@extension("additionalProperties", false)
model DnfRemove {
  /** List of RPM packages to remove. */
  packages: Array<string>;

  /** Whether to remove unused dependencies during removal operation. */
  `auto-remove`?: boolean = true;
}

@extension("additionalProperties", false)
model DnfReplace {
  /** URL to the source COPR repo for the new packages. */
  `from-repo`: string;

  /** List of packages to replace using packages from the defined repo. */
  packages: Array<string | DnfSwap>;

  ...DnfInstallCommon;
}

@extension("additionalProperties", false)
model DnfSwap {
  /** The package to be replaced. */
  old: string;

  /** The package to replace with. */
  new: string;

  /** Whether to allow erasing (removal) of packages in case of dependency problems. */
  `allow-erasing`?: boolean = false;
}

@extension("additionalProperties", false)
model DnfGroupInstall {
  /** List of RPM groups to install. */
  packages: Array<string>;

  /** Include optional packages from group. */
  `with-optional`?: boolean = false;

  ...DnfInstallCommon;
}

@extension("additionalProperties", false)
model DnfGroupRemove {
  /** List of RPM groups to remove. */
  packages: Array<string>;
}

@extension("additionalProperties", false)
model DnfInstallCommon {
  /** Whether to install weak dependencies. */
  `install-weak-deps`?: boolean = true;

  /** Whether to continue with the install if there are no packages available in the repository. */
  `skip-unavailable`?: boolean = false;

  /** Whether to continue with the install if there are broken packages. */
  `skip-broken`?: boolean = false;

  /** Whether to allow erasing (removal) of packages in case of dependency problems. */
  `allow-erasing`?: boolean = false;

  /** A list of packages to prevent from being installed */
  exclude?: Array<string>;
}
