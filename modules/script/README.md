# `script`

The `script` module can be used to run arbitrary scripts at image build time that take no or minimal external configuration (in the form of command line arguments).
The scripts, which are run from the `config/scripts` directory, are declared under `scripts:`.

## Creating a Script

Look at `example.sh` for an example shell script. You can rename and copy the file for your own purposes. In order for the script to be executed, declare it in the recipe

When creating a script, please make sure

- ...its filename ends with `.sh`.
    - This follows convention for (especially bash) shell scripts.
- ...it starts with a [shebang](<https://en.wikipedia.org/wiki/Shebang_(Unix)>) like `#!/usr/bin/env bash`.
    - This ensures the script is ran with the correct interpreter / shell.
- ...it contains the command `set -euo pipefail` right after the shebang.
    - This will make the image build fail if your script fails. If you do not care if your script works or not, you can omit this line.