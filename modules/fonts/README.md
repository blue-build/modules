# `fonts` Module for Startingpoint

The `fonts` module can be used to install [nerd-fonts](https://www.nerdfonts.com/) or [google-fonts](https://fonts.google.com/). This module will always download the latest version and properly configure fonts.

## Example configuration

```yaml
- type: fonts
  fonts:
    nerd-fonts:
      - FiraCode # don't add "Nerd Font" suffix.
      - Hack
      - SourceCodePro
      - Terminus
      - JetBrainsMono
      - NerdFontsSymbolsOnly
    google-fonts:
      - Roboto
      - Open Sans
```
