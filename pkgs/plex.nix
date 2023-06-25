{ pkgs, lib, ... }:
let
  plexname = "umini";
  myPlex = pkgs.plex.override {
    plexRaw = pkgs.plexRaw.overrideAttrs(old: rec {
      version =  "1.32.5.7210-77f7f99fa"; # "1.25.2.5319-c43dc0277";
      src = pkgs.fetchurl {
        url = "https://downloads.plex.tv/plex-media-server-new/${version}/debian/plexmediaserver_${version}_amd64.deb";
        sha256 = "sha256-1QpceTM2/MdYt1qv/XozJfKE/6S7i1d1YiYj5M0exbM=";
      };
    });
  };
in {
  services.plex = {
    enable = true;
    openFirewall = true;
    package = myPlex;
    user = "plex";
    group = "plex";
    dataDir = "/data/plex-${plexname}";
  };
}
