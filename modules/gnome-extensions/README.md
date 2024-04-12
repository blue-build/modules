# `gnome-extensions`

The `gnome-extensions` module can be used to install Gnome extensions inside system directory.

This module is universally compatible with all distributions which ship Gnome, as it's not tied to specific distribution packaging format for installing extensions.

Almost all Gnome extensions are compatible for installation.

Thanks to https://extensions.gnome.org which provides releases of extensions as zips, it is very easy to maintain this module configuration.  
The only maintenance is to bump the extension version when new Fedora/Gnome releases (around every 6 months).

What does this module do?  
- It parses the extension input from module recipe file, which is part of the download URL
- It downloads the extension directly from https://extensions.gnome.org
- Downloaded extension archive is then extracted to temporary directory
- All of its extracted files are copied to the appropriate final directories  
  (`/usr/share/gnome-shell/extensions`, `/usr/share/glib-2.0/schemas`, & `/usr/share/locale`)
- Gschema is finally compiled to include the copied extensions schemas to its database

# Usage

## Install

How to install extensions using the module:  
1. Go to https://extensions.gnome.org
2. Search for the extension that you want to install and open its extension page
3. Select the correct GNOME shell version & extension version from the dropdown
   - The command `gnome-shell --version` can be used to get the GNOME version of a running system.
4. When the download dialog for the extension comes up, copy everything but the `.shell-extension.zip` suffix from the filename into the `install:` array in this module's configuration.

An extension might need additional system dependencies in order to function.  
In that case, you should install the required dependencies before the `gnome-extensions` module is ran.
Information about the required dependencies (if any) are usually on the extension's page.  

## Uninstall

1. Open your extension manager or list the contents of the system extensions directory (`/usr/share/gnome-shell/extensions`) and pick the extensions you want to remove.
2. Get the UUID of the form `extension-name@author.url` of the extension (will
   be listed in the extension manager, or just be the directory name of the
   extension in the filesystem).
3. Put the UUID in the module's `uninstall` list.
