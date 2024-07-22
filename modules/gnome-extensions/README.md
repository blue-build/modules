# `gnome-extensions`

:::caution
The legacy configuration format, which uses a part of the extension download URL to declare extensions to install, is still supported. However, it is advised to migrate to new configuration, since it offers the benefits of a clearer configuration & automatic installation of the latest extension version compatible with the GNOME version in the image. The new configuration format is showcased below in detail.
:::

The `gnome-extensions` module can be used to install Gnome extensions inside system directory.  
It also supports uninstallation as well, for extensions which are not installed through OS package manager.

This module is universally compatible with all distributions which ship Gnome, as it's not tied to specific distribution packaging format for installing extensions.

Almost all Gnome extensions are compatible for installation.

Thanks to https://extensions.gnome.org which provides releases of extensions as zips, it is very easy to maintain this module configuration.  

What does this module do?  
- It checks the current Gnome version of your image
- It parses the extension name input from module recipe file
- It processes the jsquery from https://extensions.gnome.org using the extension name input,  
  which contains useful info about latest extension version compatible with Gnome version of your image 
- Download archive URL is formed based on the info above  
- Downloaded extension archive is then extracted to temporary directory
- All of its extracted files are copied to the appropriate final directories  
  (`/usr/share/gnome-shell/extensions`, `/usr/share/glib-2.0/schemas`, & `/usr/share/locale`)
- Gschema is finally compiled to include the copied extensions schemas to its database

Uninstallation step is performed similarly, except it obviously removes files from the mentioned final directories.

## Usage

### Extension Installation

By default, latest extension version compatible with Gnome version of your image, is installed.

How to install extensions using the module:  
1. Go to https://extensions.gnome.org or preferably [Extension Manager](https://github.com/mjakeman/extension-manager) application
2. Search for the extension that you want to install and open its extension page
3. If browsing through https://extensions.gnome.org, select the correct GNOME shell version, which matches the GNOME shell version of your image
   - The command `gnome-shell --version` can be used to get the GNOME version of a running system.
   If there is no GNOME shell version of the extension that matches the GNOME version of your image, that means that extension is not compatible
4. Copy the extension name & input it in module recipe (it is case-sensitive, so be sure that you copied it correctly)

An extension might need additional system dependencies in order to function.  
In that case, you should install the required dependencies before the `gnome-extensions` module is ran.  
Information about the required dependencies (if any) are usually on the extension's page.  

### Extension Uninstallation

Extension uninstallation can be useful to uninstall extensions from the base image,  
which are not installed through OS package manager (like extensions installed from `gnome-extensions` module).

However, if extensions in the base image are installed through OS package manager, than they should be removed through it instead.

How to uninstall extensions using the module:  
1. Go to Gnome Extensions app, https://extensions.gnome.org/local/ or [Extension Manager](https://github.com/mjakeman/extension-manager) application
2. List of installed system extensions should be presented
3. Copy the extension name & input it in module recipe (it is case-sensitive, so be sure that you copied it correctly)

## Known issues
  
### Some extensions use extension-only gschemas.compiled file location

This is a rarity, but some extensions might have this issue, due to the way they are programmed with hard-coded gschema locations.  
Most extensions which follow Gnome extension standards don't have this issue.

Standard location for global `gschema.compiled` file is:  
`/usr/share/glib-2.0/schemas/gschema.compiled`

Those problematic extensions explicitly ask for this extension-only location instead:  
`/usr/share/gnome-shell/extensions/$EXT_UUID/schemas/gschemas.compiled`

If you get the error similar to this one (Fly-Pie extension example):  
```
GLib.FileError: Failed to open file “/usr/share/gnome-shell/extensions/flypie@schneegans.github.com/schemas/gschemas.compiled”: open() failed: No such file or directory
```

Then please open the issue in BlueBuild Modules GitHub repo with the affecting extension, as it's trivial to fix.  
https://github.com/blue-build/modules/issues/new

### Some extensions published in https://extensions.gnome.org are hard-coded to user locations

Those type of extensions are fixed to these locations (... indicates further folders):  
- `/usr/local/share/...` (local system location)  
- `$HOME/.local/share/...` (user location)

Those locations are not writable in build-time.

`/usr/share/...` is the standard location for system Gnome extensions, as outlined in "What does this module do?" section.

That means that the extension has build instructions for packagers to build the extension either system-wide or user-wide.

While some extensions might not have this limit even with the instructions above, some extensions might have.

GSConnect from https://extensions.gnome.org has this limitation & requires the system version of the extension to make it work successfully.  
Those system versions are usually provided by the system packagers.

So the solution is to install the extension from system repository instead if available.

In this scenario, you will notice the extension error similar to this when trying to run it (notice the explicit request to `/usr/local/share/...` location):  
```
GLib.FileError: Failed to open file “/usr/local/share/glib-2.0/schemas/gschemas.compiled”: open() failed: No such file or directory
```
