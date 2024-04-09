# BlueBuild Modules &nbsp; [![build-ublue](https://github.com/blue-build/modules/actions/workflows/build.yml/badge.svg)](https://github.com/blue-build/modules/actions/workflows/build.yml)

This repository contains the default official module repository for [BlueBuild](https://blue-build.org/). See [./modules/](./modules/) for the module source code. See the [website](https://blue-build.org/reference/module/) for module documentation. See [How to make a custom module](https://blue-build.org/how-to/making-modules/) and [Contributing](https://blue-build.org/learn/contributing/) for help with making custom modules and contributing.

## Style & code guidelines for official bash modules

These are general guidelines for writing official bash modules and their documentation to follow in order to keep a consistent style. Not all of these are to be mindlessly followed, especially the ones about grammar and writing style, but it's good to keep these in mind if you intend to contribute back upstream, so that your module doesn't feel out of place.

### Glossary

**Module-maintainer:** Maintainer of a BlueBuild bash module. The intended audience of this section of the documentation.
**Image-maintainer:** Maintainer of a custom image that uses BlueBuild.
**Local-user:** User of a custom image using the BlueBuild bash module. The image-maintainer is usually a local-user too.

### Code Rules

- Echo what you're doing on each step and on errors to help debugging.
- Implement error-checks for scenarios where the image-maintainer might misconfigure the module.
- Use `snake_case` for functions and variables changed by the code.
- Use `SCREAMING_SNAKE_CASE` for variables that are set once and stay unchanged.
- Use `"${variable_name}"` when you want to expose information from the variable & to ensure that variables are properly parsed as strings."
- If you want to insert another regular string as a suffix or prefix to the `"${variable_name}"`, you should do that in this format: `"prefix-${variable_name}-suffix"`
- Use `set -euo pipefail` at the start of the script, to ensure that module will fail the image build if error is caught.
     -  You can also use `set -euxo pipefail` during debugging, where each executed command is printed. This should not be used in a published module. 

### Documentation

Every public module should have a `module.yml` ([reference](https://blue-build.org/reference/module/#moduleyml)) file for metadata and a `README.md` file for an in-depth description. 

For the documentation of the module in `README.md`, the following guidelines apply:
- At the start of each _paragraph_, refer to the module using its name or with "the module", not "it" or "the script".
- Use passive grammar when talking about the user, i.e. "should be used", "can be configured", preferring references to what the module does, i.e. "This module downloads the answer to the ultimate question of life, the universe and everything..." instead of what the user does, i.e. "A user can configure this module to download 42".
- When talking about directories, postfix the file path with a slash, i.e. `/path/to/system/folder/` or `config/folder-in-user-repo/`. When not talking about directories, do not postfix the file path with a slash, i.e. `/path/to/system/file`.

For the short module description (`shortdesc:`), the following guidelines apply:
- The description should start with a phrase like "The glorb module reticulates splines" or "The tree module can be used to plant trees".

### Local Module Config

**Local module config** is used to allow local-users to see & change the behavior of the module on booted system, in order to improve local-user experience.

Example of the module which satisfies the requirements & implements this functionality: `default-flatpaks`

#### Config Requirements
**Requirements** for local module configs exist, as not all modules need this functionality.  
Following conditions for approved local module config implementation are:

- **module performs it's functions on booted system**  
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
`/usr/share/bluebuild/module-name/config.yml`

**System config** is a module config which is derived from `recipe.yml` module entry. It is placed in this read-only directory location in order to avoid local-users writing to it. So it is used to inform local-users about which modifications are done in `recipe.yml`, so they can potentially proceed with modifications on their own.

**Local-user config:**  
`/usr/etc/bluebuild/module-name/config.yml`

**Local-user config** is a module config which is derived from local-user config template. It is placed in `/usr/etc`, which is then automatically copied to `/etc`, which is writable to local-users. `/usr/etc` local-user config can be used to reset module config that is done in `/etc`.

System & local-user config is not there just for users, it is also directly utilized by the module, which reads the `config.yml` file & further parses the data to allow the module to have local config functionality.

#### Config Example

System config (`/usr/share/bluebuild/default-flatpaks/config.yml`):

```yaml
# Information about the config file
#
# vendor: BlueBuild
# module: default-flatpaks
# description: System config file for `default-flatpaks` BlueBuild module, which is used to install + remove flatpak apps or modify flatpak repos.
# instructions: Read this system config in order to know what is currently configured by the system & what to potentially modify in local-user config (/etc/bluebuild/default-flatpaks/config.yml).

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

Local-user config (`/etc/bluebuild/default-flatpaks/config.yml`):

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
