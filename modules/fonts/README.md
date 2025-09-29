# fonts

The `fonts` module can be used to install fonts from [Nerd Fonts](https://www.nerdfonts.com/), [Google Fonts](https://fonts.google.com/), or arbitrary URLs. This module will always download the latest version of a font and properly configure it.

## Features

- **Nerd Fonts**: Install any font from the Nerd Fonts collection
- **Google Fonts**: Install any font from Google Fonts  
- **URL Fonts**: Install fonts from custom URLs (ZIP archives, individual font files, etc.)

## Usage
```yaml
type: fonts
fonts:
  nerd-fonts:
    - FiraCode # don't add spaces or "Nerd Font" suffix
    - Hack
    - SourceCodePro
    - Terminus
    - JetBrainsMono
    - NerdFontsSymbolsOnly
  google-fonts:
    - Roboto
    - Open Sans
    - Inter
  url-fonts:
    - name: CustomFont
      url: https://example.com/my-font.otf
    - name: CompanyFonts
      url: https://company.com/fonts.tar.gz
```

## Font Sources

### Nerd Fonts
- Downloads from the official [Nerd Fonts releases](https://github.com/ryanoasis/nerd-fonts/releases)
- Includes programming ligatures and thousands of glyphs/icons
- Perfect for terminal and code editor use

### Google Fonts  
- Downloads from [Google Fonts](https://fonts.google.com/)
- High-quality web and print fonts
- Automatically fetches the latest versions

### URL Fonts
- Download fonts from any public URL
- Supports multiple archive formats: `.zip`, `.tar.gz`, `.tar.bz2`, `.tgz`
- Supports individual font files: `.otf`, `.ttf`
- Each font is organized in its own subdirectory based on the name you specify

#### URL Fonts Examples

**Individual Font File:**
```yaml
url-fonts:
  - name: MyFont
    url: https://example.com/MyFont-Regular.otf
```

**Corporate/Licensed Fonts from ZIP Archive:**
```yaml
url-fonts:
  - name: CompanyBrand
    url: https://assets.company.com/fonts/brand-fonts.zip
```

**Multiple Fonts from GitHub Releases:**
```yaml
url-fonts:
  - name: SpecialFont
    url: https://github.com/user/repo/releases/download/v1.0/font.tar.gz
  - name: AnotherFont
    url: https://github.com/user/repo/releases/download/v2.0/font.zip
```

## Installation Locations

Fonts are installed to:
- **Nerd Fonts**: `/usr/share/fonts/nerd-fonts/`
- **Google Fonts**: `/usr/share/fonts/google-fonts/`  
- **URL Fonts**: `/usr/share/fonts/url-fonts/`

## Notes

- All fonts are automatically registered with the system font cache (`fc-cache`)
- URL fonts are organized by the name you specify
- Archives are automatically extracted and only font files (`.otf`, `.ttf`) are kept
- Font downloads are cached during the build process for efficiency

## Troubleshooting

- Ensure URLs are publicly accessible (no authentication required)
- For ZIP files, font files can be in subdirectories - they'll be found automatically  
- Use descriptive names for URL fonts to avoid conflicts
- Check that your font URLs return the expected file format
