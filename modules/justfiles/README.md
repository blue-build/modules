# `justfiles`

:::note
The module is only compatible with Universal Blue images.
:::

The `justfiles` module makes it easy to include [just](https://just.systems/) recipes from multiple files in Universal Blue -based images. It can be useful for example when utilizing DE-specific justfiles when building multiple images. On the other hand, you likely wont need the module if you're building just one image or need just one justfile for all your images.

## What is just ?

Just is a command runner (kind of like make) that can be used to supply arbitrary scripts under a single shell command. Images based on Universal Blue bundle a set of these scripts, called recipes, which can be accessed with the `ujust` command.

For more information, refer to these links:

* [Official just documentation](https://just.systems/man/en)
* [Universal Blue documentation](https://docs.bazzite.gg/Installing_and_Managing_Software/ujust/)
* [BlueBuild documentation](https://blue-build.org/learn/universal-blue/#custom-just-recipes)

## What the module does

1. The module checks if the `files/justfiles/` folder is present.
    
    * If it's not there, it fails.

2. The module finds all `.just` files inside of the `files/justfiles/` folder or starting from the relative path specified under `include`.
    
    * If no `.just` files are found, it fails.

    * The structure of the `files/justfiles/` folder does not matter, folders/files can be placed in there however desired, the module will find all `.just` files.

    * Optionally, the `.just` files can be validated.

3. The module copies over the files/folders containing `.just` files to `/usr/share/bluebuild/justfiles/`.

    * The folder structure of the copy destination remains the same as in the config folder.

4. The module generates import lines and appends them to the `/usr/share/ublue-os/just/60-custom.just` file.
    
    * The module does not overwrite the destination file. New lines are added to an existing file.

    * If the generated import lines are already present, the module skips them to avoid duplications.

## How to use the module

Place all your `.just` files or folders with `.just` files inside the `files/justfiles/` folder. If that folder doesn't exist, create it.

By default, the module will import all files with names ending in `.just` from `files/justfiles/`. You can also specify files or subfolders under `include`, and they will be the only ones imported.

If you also want to validate your justfiles, set `validate: true`. The validation can be very unforgiving and is turned off by default.

* The validation command usually prints huge number of lines. To avoid cluttering up the logs, the module will only tell you which files did not pass the validation. You can then use the command `just --fmt --check --unstable --justfile <DESTINATION FILE>` to troubleshoot them.
