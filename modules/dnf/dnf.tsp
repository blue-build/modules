import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/dnf.json")
model DnfModule {
    /** The dnf module offers pseudo-declarative package and repository management using dnf.
     * https://blue-build.org/reference/modules/dnf/
     */
    type: "dnf";

    /** List of links to .repo files to download into /etc/yum.repos.d/. */
    repos?: Array<string>;

    /** List of COPR project repos to download into /etc/yum.repos.d/. */
    copr?: Array<string>;

    /** List of links to key files to import for installing from custom repositories. */
    keys?: Array<string>;

    /** List of folder names under /opt/ to enable for installing into. */
    optfix?: Array<string>;

    /** Configuration of RPM groups removal. */
    "group-remove"?: {
        /** List of RPM groups to remove. */
        packages: Array<string>;
    };

    /** Configuration of RPM groups install. */
    "group-install"?: {
        /** List of RPM groups to install. */
        packages: Array<string>,
        /** Whether to install weak dependencies during the RPM group install or not. */
        "install-weak-dependencies"?: boolean = true,
        /** Whether to continue with the RPM group install if there are no packages available in the repository. */
        "skip-unavailable-packages"?: boolean = false,
        /** Whether to continue with the RPM group install if there are broken packages. */
        "skip-broken-packages"?: boolean = false,
        /** Whether to allow erasing (removal) of packages in case of dependency problems during the RPM group install. */
        "allow-erasing-packages"?: boolean = false;        
    };

    /** Configuration of RPM packages removal. */
    "remove"?: {
        /** List of RPM packages to remove. */
        packages: Array<string>,
        /** Whether to remove unused dependencies during removal operation. */
        "remove-unused-dependencies"?: boolean = true;        
    };

    /** Configuration of RPM packages install. */
    "install"?: {
        /** List of RPM packages to install. */
        packages: Array<string>,
        /** Whether to install weak dependencies during the RPM package install or not. */
        "install-weak-dependencies"?: boolean = true,
        /** Whether to continue with the RPM package install if there are no packages available in the repository. */
        "skip-unavailable-packages"?: boolean = false,
        /** Whether to continue with the RPM package install if there are broken packages. */
        "skip-broken-packages"?: boolean = false,
        /** Whether to allow erasing (removal) of packages in case of dependency problems during the RPM package install. */
        "allow-erasing-packages"?: boolean = false;        
    };

    /** List of configurations for replacing packages from another repo. */
    replace?: Array<{
        /** URL to the source COPR repo for the new packages. */
        "from-repo": string,
        /** List of packages to replace using packages from the defined repo. */
        packages: Array<string>,
        /** Whether to install weak dependencies during the replacement or not. */
        "install-weak-dependencies"?: boolean = true,
        /** Whether to continue with the replacement if there are no packages available on the system to replace. */
        "skip-unavailable-packages"?: boolean = false,
        /** Whether to continue with the replacement if there are broken packages in the system during the replacement. */
        "skip-broken-packages"?: boolean = false,
        /** Whether to allow erasing (removal) of packages in case of dependency problems during the replacement. */
        "allow-erasing-packages"?: boolean = false;        
    }>;
}
