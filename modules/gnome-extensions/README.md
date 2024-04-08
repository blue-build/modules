# `gnome-extensions`

The `gnome-extensions` module can be used to install Gnome extensions inside system directory.

This module is universally compatible with all distributions which ship Gnome, as it's not tied to specific distribution packaging format for installing extensions.  

Almost every Gnome extension is compatible for installation.  
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

To use this module, you need to input gettext-domain of the extension without @ symbol + the version of the extension in `.v%VERSION%` format.  
You can see gettext-domain of the extension by looking at the extension repo inside metadata.json  
or by simply downloading the zip file from https://extensions.gnome.org & than looking at the download URL part after `/extension-data/` & before `.v%VERSION%`.

You must assure that version of the extension is compatible with current Gnome version that your image is using.  
You can easily see this information when downloading extension from https://extensions.gnome.org

# Known Issues

Some extensions like GSConnect may lack information in metadata.json, like lack of `uuid`, `settings-schema` or `shell-version` key,  
which is necessary for the module to automatically install extension. Developer can easily fix this issue, so it's advised to inform him if this issue occured.
