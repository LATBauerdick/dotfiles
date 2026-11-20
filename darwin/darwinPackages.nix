{pkgs}:
let systemPackages = with pkgs; [

       darwin.linux-builder
       vim
       git

    ];
    fontsPackages = [
          #"FiraCode"
          #"DroidSansMono"
          # "Iosevka Term" for Ghostty (users/user/ghostty/config); prebuilt, as on upro
          (pkgs.iosevka-bin.override { variant = "SGr-IosevkaTerm"; })
          # "Iosevka Nerd Font" / "… Mono" for Rex, which lists only installed fonts
          pkgs.nerd-fonts.iosevka
          # pkgs.nerd-fonts.lekton
          # pkgs.nerd-fonts.jetbrains-mono
    ];
in
  {
    systemPackages = systemPackages;
    fontsPackages = fontsPackages;
  }
