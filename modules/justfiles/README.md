# `justfiles`

:::note The module is only compatible with Universal Blue images. :::

The `justfiles` module allows for easy `.just` files importing. It can be useful for example to separate DE specific justfiles when building multiple images.

## What is just and what is a justfile ?

`just` is a tool for running pre-defined commands or scripts.

The commands/scripts otherwise called recipes are defined in a file named `justfile`. That file can also contain import lines, allowing to include recipes from other files that usually end with the `.just` postfix.

Without specifying any arguments, `just` will run the first recipe defined in a `justfile` of the current directory. If the current directory doesn't contain a `justfile`, `just` will attempt to find the nearest `justfile` going back the current directory path.

In all Universal Blue images, `just` is preinstalled and a `.justfile` is created by default in the `$HOME` directory. It contains an import line that includes Universal Blue recipes and if this module was used, it will also include all recipes from the `.just` files this module worked with.

* This means if you run `just` from anywhere in your `$HOME` directory, `$HOME/.justfile` will be considered the nearest (unless there's another `justfile` in the directory path as mentioned before) and all your recipes + recipes from Universal Blue should be available.

* Universal Blue also includes the command `ujust`, that specifies what `justfile` to use, meaning all your recipes + recipes from Universal Blue will be available from anywhere, even if there is another `justfile` in your current directory path.

### Usage examples

Run a specific recipe from the nearest justfile by including its name as the first argument:
    
* `just build-a-program`

List all recipes from the nearest justfile using:
    
* `just --list`

Specify a justfile to be used:

* `just --justfile <DESTINATION FILE>`

### More information

* [Official just documentation](https://just.systems/man/en)

## What the module does

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

    * If the generated import lines are already present, the module skips them to avoid duplications.

## How to use the module

Place all your `.just` files or folders with `.just` files inside the `config/justfiles/` folder. If that folder doesn't exist, create it.

Without specifying `include`, the module will assume you want to import everything. Otherwise, specify your files/folders under `include`.

If you also want to validate your justfiles, set `validate: true`. The validation can be very unforgiving and is turned off by default.

* The validation command usually prints huge number of lines. To avoid cluttering up the logs, the module will only tell you which files did not pass the validation. You can then use the command `just --fmt --check --unstable --justfile <DESTINATION FILE>` to troubleshoot them.
