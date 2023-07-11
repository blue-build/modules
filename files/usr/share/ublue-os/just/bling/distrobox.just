update-distrobox-git:
  echo 'Installing latest git snapshot of Distrobox'
  curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sh -s -- --next --prefix ~/.local

[private]
create-distrobox PRETTY_NAME IMAGE_TAG CONTAINER_NAME:
  echo "Creating {{PRETTY_NAME}} distrobox..."
  distrobox create -i quay.io/toolbx-images/{{IMAGE_TAG}} -n {{CONTAINER_NAME}} -Y

distrobox-almalinux: (create-distrobox "Alma Linux" "almalinux-toolbox:latest" "alma")

distrobox-alpine: (create-distrobox "Alpine" "alpine-toolbox:edge" "alpine")

distrobox-archlinux: (create-distrobox "Arch Linux" "archlinux-toolbox:latest" "arch")

distrobox-centos: (create-distrobox "Centos Stream" "centos-toolbox:stream9" "centos")

distrobox-rocky: (create-distrobox "Rocky Linux" "rockylinux-toolbox:latest" "rocky")
 

distrobox-gamebox:
  echo 'Creating Arch-based Gaming distrobox...'
  distrobox create -i ghcr.io/ublue-os/bazzite-arch -n bazzite-arch -Y

distrobox-bluefin:
  echo 'Creating Bluefin Ubuntu distrobox...'
  distrobox create -i ghcr.io/ublue-os/ubuntu-toolbox:latest -n bluefin-ubuntu -Y
