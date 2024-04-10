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

# Usage

How to install extensions using the module:  
1. Go to https://extensions.gnome.org
2. Search for the extension that you want to install and open its extension page
3. Select the correct GNOME shell version & extension version from the dropdown
   - The command `gnome-shell --version` can be used to get the GNOME version of a running system.
4. When the download dialog for the extension comes up, copy everything but the `.shell-extension.zip` suffix from the filename into the `install:` array in this module's configuration.

Rarely, some extensions need additional system dependencies in order to function.  
Those extensions usually note that case inside the extension description webpage.  
The solution is to install the required dependencies by using `rpm-ostree` module before `gnome-extensions` module is ran.
