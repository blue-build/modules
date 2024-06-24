import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/rpm-ostree.json")
model RpmOstreeModule {
    /** The rpm-ostree module offers pseudo-declarative package and repository management using rpm-ostree.
     * https://blue-build.org/reference/modules/rpm-ostree/
     */
    type: "rpm-ostree",

    /** List of links to .repo files to download into /etc/yum.repos.d/. */
    repos?: Array<string>,

    /** List of links to key files to import for installing from custom repositories. */
    keys?: Array<string>,

    /** List of RPM packages to install. */
    install?: Array<string>,

    /** List of RPM packages to remove. */
    remove?: Array<string>,
}