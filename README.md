# BlueBuild Modules &nbsp; [![build-ublue](https://github.com/blue-build/modules/actions/workflows/build.yml/badge.svg)](https://github.com/blue-build/modules/actions/workflows/build.yml)

This repository contains the default official module repository for [BlueBuild](https://blue-build.org/). See [./modules/](./modules/) for the module source code. See the [website](https://blue-build.org/reference/module/) for module documentation. See [How to make a custom module](https://blue-build.org/how-to/making-modules/) and [Contributing](https://blue-build.org/learn/contributing/) for help with making custom modules and contributing.

## Style guidelines for official modules

These are general guidelines for writing official modules and their documentation to follow to keep a consistent style. Not all of these are to be mindlessly followed, especially the ones about grammar and writing style, but it's good to keep these in mind if you intend to contribute back upstream, so that your module doesn't feel out of place.

### Bash

- Echo what you're doing on each step and on errors to help debugging.
- Don't echo blocks using "===", that is reserved for the code launching the modules.
- Use `snake_case` for functions and variables changed by the code.
- Use `SCREAMING_SNAKE_CASE` for variables that are set once and stay unchanged.

### Documentation

Every public module should have a `module.yml` ([reference](https://blue-build.org/reference/module/#moduleyml)) file for metadata and a `README.md` file for an in-depth description. 

For the documentation of the module in `README.md`, the following guidelines apply:
- At the start of each _paragraph_, refer to the module using its name or with "the module", not "it" or "the script".
- Use passive grammar when talking about the user, i.e. "should be used", "can be configured", preferring references to what the module does, i.e. "This module downloads the answer to the ultimate question of life, the universe and everything..." instead of what the user does, i.e. "A user can configure this module to download 42".

For the short module description (`shortdesc:`), the following guidelines apply:
- The description should start with a phrase like "The glorb module reticulates splines" or "The tree module can be used to plant trees".
