{pkgs}:
let systemPackages = with pkgs; [
       # failed to install airbuddy
#      alacritty
       # alt-tab-macos
       # not on this platform bitwarden
       # marked as broken calibre
       discord
       # not on this platform  firefox
       google-chrome
       grandperspective
       iterm2
       keycastr
       kitty
       mediathekview
       mkalias
       obsidian
       raycast
       slack
       tailscale
       xld
       # does not install xquartz
       zoom-us

      darwin.linux-builder
       vim
       git
    ];
    fontsPackages = [
          #"FiraCode"
          #"DroidSansMono"
          pkgs.nerd-fonts.iosevka
          pkgs.nerd-fonts.lekton
          pkgs.nerd-fonts.jetbrains-mono
    ];
in
  {
    systemPackages = systemPackages;
    fontsPackages = fontsPackages;
  }
