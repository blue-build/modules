# vim: set ft=make :

# run the ublue nix installer from determinate systems https://github.com/DeterminateSystems/nix-installer
nix-me-up:
  ublue-nix-install

# run the ublue nix uninstaller from determinate systems https://github.com/DeterminateSystems/nix-installer
nix-me-down:
  ublue-nix-uninstall

# enable flakes and install fleek
fleek-me-up:
  #!/bin/sh
  if grep -q "experimental-features = nix-command flakes" ~/.config/nix/nix.conf; then
    echo "Flakes enabled, all good!"
  else
    echo "Fleek requires Nix flakes to be enabled."
    read -p "Do you want to automatically enable flakes in ~/.config/nix/nix.conf? (y/n)? " choice
    if [[ $choice =~ ^[Yy]$ ]]; then
        mkdir -p ~/.config/nix
        echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
        echo "Flakes enabled."
    else
        echo "Ok, quitting..."
        exit 0
    fi
  fi
  echo "Running fleek installer..."
  curl -fsSL https://getfleek.dev/installer | bash

# install devbox
devbox:
  echo 'Setting phasers to kill. Installing nix.'
  ublue-nix-install
  echo 'Installing devbox!'
  curl -fsSL https://get.jetpack.io/devbox | bash
  echo 'You MUST reboot to continue'

# install global devbox profile with fleek's high bling setting
devbox-global:
  echo 'Installing devbox global profile.'
  devbox global pull https://devbox.getfleek.dev/high
  echo 'run "devbox global run install-bash-hook" to configure bash shell'
  echo 'run "devbox global run install-zsh-hook" to configure zsh shell'
  echo 'run "devbox global run" to see other available configuration commands'
