# `nerd-fonts` installation module

Use it to install fonts available in the [nerd-fonts](https://github.com/ryanoasis/nerd-fonts) repository. This module will run each build always downloading the latest version from properly configured fonts.

## Configuration example

```yaml

- type: nerd-fonts
    fonts:
      - FiraCode
      - Hack
      - SourceCodePro
      - Terminus
      - JetBrainsMono
      - NerdFontsSymbolsOnly

```

The name of the fonts can be seen [here](https://www.nerdfonts.com/font-downloads) and it is **not** necessary to add the *"Nerd Font"* suffix.