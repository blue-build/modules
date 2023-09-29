# `fonts` installation module

Use it to install [nerd-fonts](https://www.nerdfonts.com/font-downloads) or [google-fonts](https://fonts.google.com/). This module will run each build always downloading the latest version from properly configured fonts.

## Configuration example

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
