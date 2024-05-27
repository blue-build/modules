# `gnome-extensions`

:::caution
The legacy configuration format, which uses a part of the extension download URL to declare extensions to install, is still supported. However, it is advised to migrate to new configuration, since it offers the benefits of a clearer configuration and automatic installation of the latest extension version compatible with the GNOME version in the image. The new configuration format is showcased below in detail.
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

# Usage

## Extension Installation

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

## Extension Uninstallation

Extension uninstallation can be useful to uninstall extensions from the base image,  
which are not installed through OS package manager (like extensions installed from `gnome-extensions` module).

However, if extensions in the base image are installed through OS package manager, than they should be removed through it instead.

How to uninstall extensions using the module:  
1. Go to Gnome Extensions app, https://extensions.gnome.org/local/ or [Extension Manager](https://github.com/mjakeman/extension-manager) application
2. List of installed system extensions should be presented
3. Copy the extension name & input it in module recipe (it is case-sensitive, so be sure that you copied it correctly)
