# BlueBuild Modules &nbsp; [![build-ublue](https://github.com/blue-build/modules/actions/workflows/build.yml/badge.svg)](https://github.com/blue-build/modules/actions/workflows/build.yml)

This repository contains the default official module repository for [BlueBuild](https://blue-build.org/). See [./modules/](./modules/) for the module source code. See the [website](https://blue-build.org/reference/module/) for module documentation. See [How to make a custom module](https://blue-build.org/how-to/making-modules/) and [Contributing](https://blue-build.org/learn/contributing/) for help with making custom modules and contributing.

## Style guidelines for official modules

These are general guidelines for writing official modules and their documentation to follow to keep a consistent style. Not all of these are to be mindlessly followed, especially the ones about grammar and writing style, but it's good to keep these in mind if you intend to contribute back upstream, so that your module doesn't feel out of place.

### Bash

- Echo what you're doing on each step and on errors to help debugging.
- Don't echo blocks using "===", that is reserved for the code launching the modules.
- Use `snake_case` for functions and variables changed by the code.
- Use `SCREAMING_SNAKE_CASE` for variables that are set once and stay unchanged.

### `module.yml` (not implemented) (will replace READMEs)

Each public module should also include a `module.yml` with the following keys: (TODO, not planned yet).

#### `description:`

- At the start of each paragraph, refer to the module using its name or with "the module", not "it" or "the script"
- Use passive grammar when talking about the user, ie. "should be used", "can be configured", preferring references to what the module does, ie. "This module downloads the answer to the question of life, the universe and everything..."
