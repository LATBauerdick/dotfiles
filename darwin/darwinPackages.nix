{pkgs}:
let systemPackages = with pkgs; [
       # failed to install airbuddy
       alacritty
       alt-tab-macos
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
       xld
       # does not install xquartz
       zoom-us

       vim
       git
    ];
    fontsPackages = with pkgs; [
        (nerdfonts.override { fonts = [
          #"FiraCode" 
          #"DroidSansMono" 
          "Iosevka"
          "Lekton"
          "JetBrainsMono"
          ]; })
    ];
in
  {
    systemPackages = systemPackages;
    fontsPackages = fontsPackages;
  }
