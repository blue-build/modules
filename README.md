# BlueBuild Modules &nbsp; [![build-individual](https://github.com/blue-build/modules/actions/workflows/build-individual.yml/badge.svg)](https://github.com/blue-build/modules/actions/workflows/build-individual.yml)

This repository contains the default official module repository for [BlueBuild](https://blue-build.org/). See [./modules/](./modules/) for the module source code. See the [website](https://blue-build.org/reference/module/) for module documentation. See [How to make a custom module](https://blue-build.org/how-to/making-modules/) and [Contributing](https://blue-build.org/learn/contributing/) for help with making custom modules and contributing.

## Style & code guidelines for official bash modules

These are general guidelines for writing official bash modules and their documentation to follow in order to keep a consistent style. Not all of these are to be mindlessly followed, especially the ones about grammar and writing style, but it's good to keep these in mind if you intend to contribute back upstream, so that your module doesn't feel out of place.

### Glossary

**Module-maintainer:** Maintainer of a BlueBuild bash module. The intended audience of this section of the documentation.  
**Image-maintainer:** Maintainer of a custom image that uses BlueBuild.  
**Local-user:** User of a custom image using the BlueBuild bash module. The image-maintainer is usually a local-user too.  
**Build-time modules:** Modules that perform its functionality when image is building.  
**Run-time modules:** Modules that perform its functionality when system is booting or after system is booted.

### Code Rules

- Echo what you're doing on each step and on errors to help debugging.
- Implement error-checks for scenarios where the image-maintainer might misconfigure the module.
- Use `snake_case` for functions and variables changed by the code.  
- Use `SCREAMING_SNAKE_CASE` for variables that are set once and stay unchanged.
- Use `"${variable_name}"` when you want to expose information from the variable & to ensure that variables are properly parsed as strings.
- If you want to insert another regular string as a suffix or prefix to the `"${variable_name}"`, you should do that in this format: `"prefix-${variable_name}-suffix"`
- Use `set -euo pipefail` at the start of the script, to ensure that module will fail the image build if error is caught.
     -  You can also use `set -euxo pipefail` during debugging, where each executed command is printed. This should not be used in a published module. 
- For downloading files, we utilize `curl`. Here's the template for what we're using:  
  - Download file with differently specified filename:  
`curl -fLs --create-dirs "${URL}" -o "${DIR}/${FILENAME.EXT}"`  
  - Download file to directory with no filename changes:  
`curl -fLs --create-dirs -O "${URL}" --output-dir "${DIR}"`

Using [Shellcheck](https://www.shellcheck.net/) in your editor is recommended.

### Documentation

Every public module should have a `module.yml` (see below) file for metadata and a `README.md` file for an in-depth description. 

For the documentation of the module in `README.md`, the following guidelines apply:
- At the start of each _paragraph_, refer to the module using its name or with "the module", not "it" or "the script".
- Use passive grammar when talking about the user, i.e. "should be used", "can be configured", preferring references to what the module does, i.e. "This module downloads the answer to the ultimate question of life, the universe and everything..." instead of what the user does, i.e. "A user can configure this module to download 42".
- When talking about directories, postfix the file path with a slash, i.e. `/path/to/system/folder/` or `config/folder-in-user-repo/`. When not talking about directories, do not postfix the file path with a slash, i.e. `/path/to/system/file`.

For the short module description (`shortdesc:`), the following guidelines apply:
- The description should start with a phrase like "The glorb module reticulates splines" or "The tree module can be used to plant trees".

### `module.yml`

A `module.yml` is the metadata file for a public module, used on the website to generate module reference pages. May be used in future projects to showcase modules and supply some defaults for them.

#### `name:`

The name of the module, same as the name of the directory and script.

#### `shortdesc:`

A short description of the module, ideally not more than one sentence long. This is used in website metadata or anywhere a shorter module description is needed.

#### `example:`

A YAML string of example configuration showcasing the configuration options available with inline documentation to describe them. Some of the configuration options may be commented out, with comments describing why one might enable them. The intention here is that the example would be a good place to copy-paste from to get started.

### [TypeSpec](https://typespec.io/) schema

Every module folder should include a `<modulename>.tsp` file containing a model of the module's valid configuration options. This schema syntax should be familiar to programmers used to typed languages, especially TypeScript. The schemas will be compiled to the [JSON Schema](https://json-schema.org/) format and used for validation in editors and CLI.

- When creating a new module, you can get started easily by copying relevant parts of the `.tsp` file of a module with similar configuration.
  - Make sure to change all references to the module's name.
  - Here's an example of an empty `.tsp` file for a module. Replace `<module-name>` with the module's name in kebab-case, and `<ModuleName>` with the module's name in PascalCase.
  ```tsp
  import "@typespec/json-schema";
  using TypeSpec.JsonSchema;

  @jsonSchema("/modules/<module-name>.json")
  model <ModuleName>Module {
      /** <Short description of the module>
      * https://blue-build.org/reference/modules/<module-name>/
      */
      type: "<module-name>",
  }
  ``` 
- Use docstrings with the `/** */` syntax liberally to describe every option in the configuration.
  - Even the `type:` key should be documented as in the example above.
  - See [the TypeSpec documentation](https://typespec.io/docs/language-basics/documentation).
- Remember to use the `?` syntax to declare all properties which are not required to use the module successfully as optional. Also declare default values when applicable.
  - See [the TypeSpec documentation](https://typespec.io/docs/language-basics/models#optional-properties).
- Make sure to add a semicolon `;` to the end of all property definitions. Without this, the schema compilation will fail.

### Run-time Modules
> [!IMPORTANT]  
> Build-time modules are preferred over run-time modules for better system reliability.  
> Only implement run-time modules when build-time modules are impossible to implement for achieving desired functionality.

**Run-time modules:** Modules that perform its functionality when system is booting or after system is booted.

**Local module config** is used to allow local-users to see & change the behavior of the run-time module, in order to improve local-user experience.

Example of the run-time module which satisfies the requirements & implements this functionality: `default-flatpaks`

#### Local Module Config Requirements
**Requirements** for local module configs exist, as not all modules need this functionality.  
Following conditions for approved local module config implementation are:

- **module performs its functions on booted system**  
 Modules which are fully utilized in build-time don't need configuration options, as those are already located in `recipe.yml`.
- **local module config can be implemented without affecting reliability of the system**  
 Module-maintainer needs to carefully select which type of module to implement based on condition above. If a module compromises system reliability when used on booted system, making the module build-time based should be considered. Examples of this are `rpm-ostree` & `akmods` modules, which are better utilized as build-time modules.
- **module can have additional useful options for configuring**  
Which can improve local-user experience.
- **module can strongly collide with local-user's usage pattern with it's default behavior**  
Example: `default-flatpaks` module can remove a flatpak app, which local-user used daily.

#### Config Format

In order to keep config files easy to read & reliable to parse, standardized `.yml` markup format is used.  
[`yq`](https://github.com/mikefarah/yq) tool is used to process `.yml` configs in order to reach the desired goal.

#### Config Directory Structure

**System config:**  
`/usr/share/bluebuild/module-name/configuration.yml`

**System config** is a module config which is derived from `recipe.yml` module entry. It is placed in this read-only directory location in order to avoid local-users writing to it. So it is used to inform local-users about which modifications are done in `recipe.yml`, so they can potentially proceed with modifications on their own.

**Local-user config:**  
`/usr/etc/bluebuild/module-name/configuration.yml`

**Local-user config** is a module config which is derived from local-user config template. It is placed in `/usr/etc`, which is then automatically copied to `/etc`, which is writable to local-users. `/usr/etc` local-user config can be used to reset module config that is done in `/etc`.

System & local-user config is not there just for users, it is also directly utilized by the module, which reads the `configuration.yml` file & further parses the data to allow the module to have local config functionality.

#### Config Example

System config (`/usr/share/bluebuild/default-flatpaks/configuration.yml`):

```yaml
# Information about the config file
#
# vendor: BlueBuild
# module: default-flatpaks
# description: System config file for `default-flatpaks` BlueBuild module, which is used to install + remove flatpak apps or modify flatpak repos.
# instructions: Read this system config in order to know what is currently configured by the system & what to potentially modify in local-user config (/etc/bluebuild/default-flatpaks/configuration.yml).

# Configuration section
notify: true
system:
  install:
    - org.gnome.Boxes 
    - org.gnome.Calculator
    - org.gnome.Calendar
    - org.gnome.Snapshot
    - org.gnome.Contacts
user:
  install:
    - org.gnome.World.Secrets
```

Local-user config (`/etc/bluebuild/default-flatpaks/configuration.yml`):

```yaml
# Information about the config file
#
# vendor: BlueBuild
# module: default-flatpaks
# description: Local-user config file for `default-flatpaks` BlueBuild module, which is used to install + remove flatpak apps or modify flatpak repos.
# instructions: Template of all supported options is in a example below. Modify the options you need & set "active" key to true.

# Configuration section
active: false
notify: true # possible options: true/false
system:
  repo-url: https://dl.flathub.org/repo/flathub.flatpakrepo
  repo-name: flathub-system
  repo-title: "Flathub (System)" # Optional; this sets the remote's user-facing name in graphical frontends like GNOME Software
  install:
    - org.gnome.Boxes 
    - org.gnome.Calculator
    - org.gnome.Calendar
    - org.gnome.Snapshot
    - org.gnome.Contacts
  remove:
    - org.gnome.TextEditor
user:
  repo-url: https://dl.flathub.org/repo/flathub.flatpakrepo
  repo-name: flathub-user
  repo-title: "Flathub (User)" # Optional; this sets the remote's user-facing name in graphical frontends like GNOME Software
  install:
    - org.gnome.World.Secrets
  remove:
    - org.gnome.Contacts    
```
