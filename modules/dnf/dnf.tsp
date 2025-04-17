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
  repos?: Repo;

  /** List of folder names under /opt/ to enable for installing into. */
  optfix?: Array<string>;

  /** Configuration of RPM groups removal. */
  `group-remove`?: GroupRemove;

  /** Configuration of RPM groups install. */
  `group-install`?: GroupInstall;

  /** Configuration of RPM packages removal. */
  remove?: Remove;

  /** Configuration of RPM packages install. */
  install?: Install;

  /** List of configurations for replacing packages from another repo. */
  replace?: Array<Replace>;
}

model Repo {
  /** Cleans up the repos added in the same step after packages are installed. */
  cleanup?: boolean = false;

  /** List of paths or URLs to .repo files to import */
  files?: Array<string> | RepoFiles;

  /**
   * List of COPR project repos to add.
   * You can also specify 2 lists
   * instead to 'enable' or 'disable' COPR repos.
   */
  copr?: Array<string> | RepoCopr;

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

model RepoFiles {
  /** List of repo files/URLs to add. */
  add?: Array<string>;

  /**
   * List of repos to disable.
   * This must be the ID of the repo
   * as seen in `dnf5 repolist`.
   */
  remove?: Array<string>;
}

model RepoCopr {
  /** List of COPR repos to enable */
  enable?: Array<string>;

  /** List of COPR repos to disable */
  disable?: Array<string>;
}

model Install {
  /** List of RPM packages to install. */
  packages: Array<string | InstallRepo>;

  ...InstallCommon;
}

model InstallRepo {
  /** The repo to use when installing packages */
  repo: string;

  /** List of RPM packages to install. */
  packages: Array<string>;

  ...InstallCommon;
}

model Remove {
  /** List of RPM packages to remove. */
  packages: Array<string>;

  /** Whether to remove unused dependencies during removal operation. */
  `auto-remove`?: boolean = true;
}

model Replace {
  /** URL to the source COPR repo for the new packages. */
  `from-repo`: string;

  /** List of packages to replace using packages from the defined repo. */
  packages: Array<string | Swap>;

  ...InstallCommon;
}

model Swap {
  /** The package to be replaced. */
  old: string;

  /** The package to replace with. */
  new: string;

  /** Whether to allow erasing (removal) of packages in case of dependency problems. */
  `allow-erasing`?: boolean = false;
}

model GroupInstall {
  /** List of RPM groups to install. */
  packages: Array<string>;

  /** Include optional packages from group. */
  `with-optional`?: boolean = false;

  ...InstallCommon;
}

model GroupRemove {
  /** List of RPM groups to remove. */
  packages: Array<string>;
}

model InstallCommon {
  /** Whether to install weak dependencies. */
  `install-weak-deps`?: boolean = true;

  /** Whether to continue with the install if there are no packages available in the repository. */
  `skip-unavailable`?: boolean = false;

  /** Whether to continue with the install if there are broken packages. */
  `skip-broken`?: boolean = false;

  /** Whether to allow erasing (removal) of packages in case of dependency problems. */
  `allow-erasing`?: boolean = false;
}
