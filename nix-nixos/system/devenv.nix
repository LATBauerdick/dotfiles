
{ config, lib, pkgs, ... }:

{

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # Install some packages
  environment.systemPackages = with pkgs; [
      wireguard-tools
      sshfs
      mosh
      networkmanager
      cryptsetup
      vim
      bind      # for nslookup  
      mosh
      syncthing
      less
      man
      coreutils
      binutils gcc gnumake openssl pkgconfig
      nix-prefetch-git
  ];

  fonts.fonts = [ 
#    pkgs.cm_unicode
    pkgs.lmodern
  ];

}

