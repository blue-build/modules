# `wallpapers`

The `wallpapers` module can be used for including & setting wallpapers into desktop environments.  
It also supports advanced wallpaper functionality for Gnome desktop environment.

What does this module do?

Universal:  
- It replaces whiteline spaces with _ character for wallpaper files & folders (it's a good practice for parsing system files).  
- It copies your provided wallpapers from `config/wallpapers` into `/usr/share/backgrounds/bluebuild`.

Gnome:  
- When light+dark wallpapers are included, it automatically separates them for further manipulation process.  
- It automatically assigns all your wallpapers into background XML files located in `/usr/share/gnome-background-properties`,  
   which makes them available for selection in Gnome Appearance settings.  
- If specified, advanced scaling options are written into XML files too  
   Global scaling is always written 1st, while per-wallpaper scaling is always written last.  
- XML files are automatically renamed to "bluebuild-`name-of-wallpaper.jpg`.xml".  
   Light+dark XML files are renamed to "bluebuild-`name-of-wallpaper-bb-light.jpg`_+_`name-of-wallpaper-bb-dark.jpg`.xml".  
- Default wallpaper & default scaling is set through gschema override.  
   Default scaling mirrors global scaling, while  
   per-wallpaper scaling is only mirrored if default wallpaper is specified in scaling entry.  
- Gschema override is copied to `/tmp/bluebuild-schema-test-wallpapers` location.
- Error-checking test is performed using `glib-compile-schemas` with `--strict` flag.
- If test passes successfully, gschema override is then copied into `/usr/share/glib-2.0/schemas` location.  
- To finally apply wallpaper defaults, gschema override is then compiled with `glib-compile-schemas` normally.

For more details about Gnome wallpaper functions, please see "Usage (Gnome)" documentation section.

## Usage

To use this module, you need to include your wallpapers into this location (make folder if it doesn't exist):

`config/wallpapers`

You can also make additional folders with wallpapers inside `config/wallpapers` for better organization.

`config/wallpapers/delight`  
`config/wallpapers/forest`

Then you just need to set `type: wallpapers` into the recipe file & you're good to go.

## Usage (Gnome)

### Default wallpaper

To set your wallpaper as the default, input the wallpaper name into `default`, `wallpaper` recipe entry:

`- I-love-nature.jpg`  
`- I LOVE BLUEBUILD.png` # spaced characters are also supported as an input

Same format is used for `scaling`, `scaling-option` recipe entry.

### Light+dark wallpapers

To add light+dark wallpapers for Gnome, copy your wallpapers into this location (make folder if it doesn't exist):

`config/wallpapers/gnome-light-dark`

To make things tidy, you can also place them in separate folders, like here in example:

`config/wallpapers/gnome-light-dark/my-wallpaper-folder-1`  
`config/wallpapers/gnome-light-dark/my-wallpaper-folder-2`

Then add `-bb-light` & `-bb-dark` suffix to wallpaper file-names, to make the module additionally recognize those wallpapers as light+dark.  
Wallpapers must have the same file-name with only differentiation of `-bb-light` & `-bb-dark` suffix.

`my-wallpaper-bb-light.jpg`  
`my-wallpaper-bb-dark.jpg`

`My great wallpaper-bb-light.png`  
`My great wallpaper-bb-dark.png`

To set some light+dark wallpaper as the default,  
you need to input it into `default`, `wallpaper-light-dark` recipe entry in this format example:

`- my-default-wallpaper-bb-light.jpg + my-default-wallpaper-bb-dark.jpg`  
`- My Little Pony-bb-light.jxl + My Little Pony-bb-dark.jxl`

Order is VERY IMPORTANT here, with `light + dark` order.  
Else your light wallpaper becomes dark & vice-versa.

Same applies with setting specific scaling for light/dark wallpaper using `scaling`, `scaling-option` recipe entry.

### Wallpaper scaling

Wallpaper scaling can be useful for certain type of wallpapers, if default scaling is not sufficient for aesthetic purposes.

Default wallpaper scaling is `zoom`, which is sufficient for most wallpapers & most screen configurations.

Those wallpaper scaling options are supported for Gnome:

1. none - does not perform any scaling (black bars will be present on screens with different aspect ratios & wallpapers with higher resolution than the screen won't display at all)  
2. scaled - it scales the wallpaper according to the screen resolution (black bars will be present on screens with different aspect ratios)  
3. stretched - it stretches the wallpaper from all affected sides to eliminate black bars (ruins the natural aspect ratio of the affected wallpaper)  
4. zoom - it zooms-in the wallpaper to eliminate black bars  
5. centered - it centers the wallpaper according to the screen resolution (if wallpaper is lower in resolution than the screen, it will zoom-out with black bars)  
6. spanned - it's useful for multi-screen configurations when you want to have 1 wallpaper displayed across all of the screens (opposite of displaying the wallpaper per-screen)  
7. wallpaper - it sets the wallpaper in multiple tiles (like a mosaic)

To set different wallpaper scaling, you can use 2 wallpaper scaling ranges:  
- all  
- per-wallpaper

`all` scaling range applies scaling to all wallpapers, while respecting `per-wallpaper` entries.  
`per-wallpaper` scaling range applies scaling to selected wallpapers.

When you decide which wallpaper scaling range & option is sufficient for you,  
you can input those settings in `scaling` recipe entry as follows:

```yaml
- scaling-option: all  
- scaling-option:  
     - my-normal-wallpaper bruh.jpg  
     - my-default-wallpaper-bb-light.jpg + my-default-wallpaper-bb-dark.jpg
```
