# `script`

The `script` module can be used to run arbitrary bash snippets and scripts at image build time. This is intended for running commands that need no YAML configuration.

The snippets, which are run in a bash subshell, are declared under `snippets:`.   
The scripts, which are run from the `files/scripts/` directory, are declared under `scripts:`.

## Creating a Script

Look at `example.sh` for an example shell script. You can rename and copy the file for your own purposes. In order for the script to be executed, declare it in the recipe

When creating a script, please make sure

- ...its filename ends with `.sh`.
    - This follows convention for (especially bash) shell scripts.
- ...it starts with a [shebang](<https://en.wikipedia.org/wiki/Shebang_(Unix)>) like `#!/usr/bin/env bash`.
    - This ensures the script is ran with the correct interpreter / shell.
- ...it contains the command `set -euo pipefail` right after the shebang.
    - This will make the image build fail if your script fails. If you do not care if your script works or not, you can omit this line.
