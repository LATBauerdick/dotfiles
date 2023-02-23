
  let
    version = "1.30.1.6497-5fc2e0894";
    hash = "sha256-VwaetJED30ot62LIJi8Ix5IrIa7irbzdGFZbIqz3PgU=";
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
