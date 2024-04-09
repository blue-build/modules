# `gnome-extensions`

The `gnome-extensions` module can be used to install Gnome extensions inside system directory.

This module is universally compatible with all distributions which ship Gnome, as it's not tied to specific distribution packaging format for installing extensions.  

Almost all Gnome extensions are compatible for installation.  
Only rare intervention that might be needed is for extensions which require some additional system dependencies, like Pano.   

Thanks to https://extensions.gnome.org which provides end-releases of extensions as zips, it is very easy to maintain this module configuration.  
The only maintenance is to bump the extension version when new Fedora/Gnome releases (around every 6 months).

What does this module do?
- It parses the gettext-domain that you inputted, along with the extension version
- It downloads the extension directly from https://extensions.gnome.org
- Downloaded extension archive is then extracted to temporary directory
- All of its extracted files are copied to the appropriate final directories  
  (`/usr/share/gnome-shell/extensions`, `/usr/share/glib-2.0/schemas`, & `/usr/share/locale`)

# Usage

To use this module, you need to input gettext-domain of the extension without @ symbol + the version of the extension in `.v%VERSION%` format in module recipe.  
But for some extensions, `.v%VERSION%` is parsed as the version of package in incremental numbering, instead of extension version in https://extensions.gnome.org URL.  
So to be sure that you got the correct module input, follow the steps below.

How to gather correct module input:  
1. Go to https://extensions.gnome.org
2. Search for the extension that you want
3. Select the matching Gnome shell version & extension version that you want to download
4. When extension is downloaded, you get the info when you omit `.shell-extension.zip` suffix from the extension zip file-name
