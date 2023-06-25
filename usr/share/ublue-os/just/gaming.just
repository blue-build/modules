setup-gaming:
  echo 'Setting up gaming experience ... lock and load.'
  distrobox create -i ghcr.io/ublue-os/bazzite-arch gamebox
  flatpak install -y --user \\
  com.discordapp.Discord \\
  com.feaneron.Boatswain \\
  org.freedesktop.Platform.VulkanLayer.MangoHud//22.08 \\
  org.freedesktop.Platform.VulkanLayer.OBSVkCapture//22.08 \\
  org.freedesktop.Platform.VulkanLayer.vkBasalt//22.08 \\
  com.heroicgameslauncher.hgl \\
  com.obsproject.Studio \\
  com.obsproject.Studio.Plugin.OBSVkCapture \\
  com.obsproject.Studio.Plugin.Gstreamer \\
  com.usebottles.bottles \\
  com.valvesoftware.Steam \\
  com.valvesoftware.Steam.Utility.gamescope \\
  net.davidotek.pupgui2
  flatpak override com.usebottles.bottles --user --filesystem=xdg-data/applications
  flatpak override --user --env=MANGOHUD=1 com.valvesoftware.Steam
  flatpak override --user --env=MANGOHUD=1 com.heroicgameslauncher.hgl

emudeck:
  wget -O "$HOME/Desktop/emudeck.desktop" "https://www.emudeck.com/EmuDeck.desktop"
  chmod +x "$HOME/Desktop/emudeck.desktop"
  kioclient exec "$HOME/Desktop/emudeck.desktop"

deckyloader:
  curl -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/install_release.sh | sh
