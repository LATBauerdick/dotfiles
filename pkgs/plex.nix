{ pkgs, lib, config, ... }:
let
  # plexname = "umini";
  myPlex = pkgs.plex.override {
    plexRaw = pkgs.plexRaw.overrideAttrs(old: rec {
      version = "1.41.8.9834-071366d65";
      # version = "1.41.7.9823-59f304c16";
      # version = "1.41.6.9685-d301f511a";
      # version = "1.41.5.9522-a96edc606";
      # version = "1.41.4.9463-630c9f557";
      # version = "1.41.3.9314-a0bfb8370";
      # version = "1.41.2.9200-c6bbc1b53";
      # version = "1.41.1.9057-af5eaea7a";
      # version = "1.40.2.8395-c67dce28e";
      # version = "1.40.1.8227-c0dd5a73e";
      # "1.32.8.7639-fb6452ebf";  "1.32.5.7349-8f4248874"; "1.32.5.7318-0b5fb6462"; "1.32.5.7210-77f7f99fa"; "1.25.2.5319-c43dc0277";
      src = pkgs.fetchurl {
        url = "https://downloads.plex.tv/plex-media-server-new/${version}/debian/plexmediaserver_${version}_amd64.deb";
        sha256 = "sha256-fhm61vxJOWba2ngLzHCssqSCgO9JG7zurBJ90fSnAS4=";
      };
    });
  };
  plexname = pkgs.config.plex.plexname;
in {
 
  services.plex = builtins.trace "enable plex for >>${plexname}<<" {
    openFirewall = true;
    package = myPlex;
    user = "plex";
    group = "plex";
    dataDir = "/data/plex-${plexname}";
  };
}
