
  let
    version = "1.31.0.6654-02189b09f"; # "1.30.1.6497-5fc2e0894";
    hash = "sha256-TTEcyIBFiuJTNHeJ9wu+4o2ol72oCvM9FdDPC83J3Mc=";
  in
self: super: {

plex = super.plex.overrideAttrs (old: {
    version = version;
    src = super.fetchurl {
       url = "https://downloads.plex.tv/plex-media-server-new/${version}/debian/plexmediaserver_${version}_amd64.deb";
      sha256 = hash;
    };

  });
}
