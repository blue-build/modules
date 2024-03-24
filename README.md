# BlueBuild Modules &nbsp; [![build-ublue](https://github.com/blue-build/modules/actions/workflows/build.yml/badge.svg)](https://github.com/blue-build/modules/actions/workflows/build.yml)

This repository contains the default official module repository for [BlueBuild](https://blue-build.org/). See [./modules/](./modules/) for the module source code. See the [website](https://blue-build.org/reference/module/) for module documentation. See [How to make a custom module](https://blue-build.org/how-to/making-modules/) and [Contributing](https://blue-build.org/learn/contributing/) for help with making custom modules and contributing.

## Style & code guidelines for official bash modules

These are general guidelines for writing official bash modules and their documentation to follow in order to keep a consistent style. Not all of these are to be mindlessly followed, especially the ones about grammar and writing style, but it's good to keep these in mind if you intend to contribute back upstream, so that your module doesn't feel out of place.

### Terms

**Module-maintainer:** Maintainer of the BlueBuild bash module, to whom is this guideline targeted.  
**Image-maintainer:** Maintainer of the custom image which uses BlueBuild template.  
**Local-user:** User which uses a custom image, which utilizes BlueBuild bash modules. Image-maintainer can be a local-user too at the same time.

### Code Rules

- Echo what you're doing on each step and on errors to help debugging.
- Implement error-checks for scenarios where image-maintainer can make a mistake.
- Use `snake_case` for functions and variables changed by the code.
- Use `SCREAMING_SNAKE_CASE` for variables that are set once and stay unchanged.
- Use `"${snake_case}"` to ensure that variables are properly parsed for strings.
- Use `set -euo pipefail` at the start of the script, to ensure that module will fail the image build if error is caught.
- Use `set -euxo pipefail` at the start of the script for debugging, as each executed command is printed. Only use it for testing & not for final release.

### Documentation

Every public module should have a `module.yml` ([reference](https://blue-build.org/reference/module/#moduleyml)) file for metadata and a `README.md` file for an in-depth description. 

For the documentation of the module in `README.md`, the following guidelines apply:
- At the start of each _paragraph_, refer to the module using its name or with "the module", not "it" or "the script".
- Use passive grammar when talking about the user, i.e. "should be used", "can be configured", preferring references to what the module does, i.e. "This module downloads the answer to the ultimate question of life, the universe and everything..." instead of what the user does, i.e. "A user can configure this module to download 42".
- When talking about directories, postfix the file path with a slash, i.e. `/path/to/system/folder/` or `config/folder-in-user-repo/`. When not talking about directories, do not postfix the file path with a slash, i.e. `/path/to/system/file`.

For the short module description (`shortdesc:`), the following guidelines apply:
- The description should start with a phrase like "The glorb module reticulates splines" or "The tree module can be used to plant trees".

### Module Config

**Module config** is used to allow local-users to see & change the behavior of the module on booted system, in order to improve local-user experience.

#### Config Requirements
**Requirements** for module configs exist, as not all modules need this functionality.  
Following conditions for approved module config implementation is:

- **module performs it's functions on booted system**  
 Modules which are fully utilized in build-time don't need configuration options, as those are already located in `recipe.yml`.
- **module config can be implemented without affecting reliability of the system**  
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
`/usr/share/bluebuild/module-name/module-config.yml`

**System config** is a module config which is derived from `recipe.yml` module entry. It is placed in this read-only directory location in order to avoid local-users touching that file.

**Local-user config:**  
`/usr/etc/bluebuild/module-name/module-config.yml` 

**Local-user config** is a module config which is derived from local-user config template. It is placed in `/usr/etc`, which is then automatically copied to `/etc`, which is writable to local-users. `/usr/etc` local-user config can be used to reset module config that is done in `/etc`.

#### Config Example

System config:

```yaml
description: System config file for `system flatpak installation` used by the `default-flatpaks` BlueBuild module.
instructions: Flatpak ID format is used for system flatpak installation.
install:
  - org.gnome.Boxes 
  - org.gnome.Calculator
  - org.gnome.Calendar
  - org.gnome.Snapshot
  - org.gnome.Contacts
```

Local-user config:

```yaml
description: Local-user config file for `system flatpak installation` used by the `default-flatpaks` BlueBuild module.
instructions: Flatpak ID format is used for system flatpak installation. Insert entries with removed # starting symbol.
install:
  # - org.gnome.Boxes 
  # - org.gnome.Calculator
  # - org.gnome.Calendar
  # - org.gnome.Snapshot
  # - org.gnome.Contacts
```
