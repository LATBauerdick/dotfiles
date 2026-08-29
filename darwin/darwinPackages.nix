{pkgs}:
let systemPackages = with pkgs; [

       darwin.linux-builder
       vim
       git

    ];
    fontsPackages = [
          #"FiraCode"
          #"DroidSansMono"
          # pkgs.nerd-fonts.iosevka
          # pkgs.nerd-fonts.lekton
          # pkgs.nerd-fonts.jetbrains-mono
    ];
in
  {
    systemPackages = systemPackages;
    fontsPackages = fontsPackages;
  }
