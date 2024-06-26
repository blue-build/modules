# `justfiles`

The `justfiles` module allows for easy `.just` files importing. It can be useful for example to separate DE specific justfiles when building multiple images.

## What it does

1. The module checks if the `config/justfiles/` folder is present.
    
    * If it's not there, it fails.

2. The module finds all `.just` files inside of the `config/justfiles/` folder or starting from the relative path specified under `include`.
    
    * If no `.just` files are found, it fails.

    * The structure of the `config/justfiles/` folder does not matter, folders/files can be placed in there however desired, the module will find all `.just` files.

    * Optionally, the `.just` files can be validated.

3. The module copies over the files/folders containing `.just` files to `/usr/share/bluebuild/justfiles/`.

    * The folder structure of the copy destination remains the same as in the config folder.

4. The module generates import lines and appends them to the `/usr/share/ublue-os/just/60-custom.just` file.
    
    * The module does not overwrite the destination file. New lines are added to an existing file.

    * If the generated import lines are already present, the module fails to avoid duplications.

## How to use it

Place all your `.just` files or folders with `.just` files inside the `config/justfiles/` folder. If that folder doesn't exist, create it.

Without specifying `include`, the module will assume you want to import everything. Otherwise, specify your files/folders under `include`.

If you also want to validate your justfiles, set `validate: true`. The validation can be very unforgiving and is turned off by default.

* The validation command usually prints huge number of lines. To avoid cluttering up the logs, the module will only tell you which files did not pass the validation. You can then use the command `just --fmt --check --unstable --justfile <DESTINATION FILE>` to troubleshoot them.
