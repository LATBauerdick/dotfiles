{ pkgs, lib, config, ... }:
let
  version = "1.43.3.10896-cb3ebc72d";
  # version = "1.43.0.10492-121068a07";
  # version = "1.42.2.10156-f737b826c";
  # version = "1.42.1.10060-4e8b05daf";
  # version = "1.41.9.9961-46083195d";
  # version = "1.41.8.9834-071366d65";
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

  # Plex ships one .deb per architecture. Pinning only the amd64 file is what
  # made plex "Exec format error" on upro (aarch64, 2026-09-17); keep a hash per
  # arch so umac and upro run the same version. When bumping `version`:
  #   nix store prefetch-file https://downloads.plex.tv/plex-media-server-new/<v>/debian/plexmediaserver_<v>_amd64.deb
  #   nix store prefetch-file https://downloads.plex.tv/plex-media-server-new/<v>/debian/plexmediaserver_<v>_arm64.deb
  debArch = {
    x86_64-linux = "amd64";
    aarch64-linux = "arm64";
  }.${pkgs.stdenv.hostPlatform.system};
  debHash = {
    amd64 = "sha256-qgnyZt3PQI4Qz3ulYbbkVObhCbqUFjlraWW9THnzcUk=";
    arm64 = "sha256-KnrRMGeV05FVHXeO7CHmQm/P79lfC7KIdxYR9i2OfS0=";
  }.${debArch};

  myPlex = pkgs.plex.override {
    plexRaw = pkgs.plexRaw.overrideAttrs (old: {
      inherit version;
      src = pkgs.fetchurl {
        url = "https://downloads.plex.tv/plex-media-server-new/${version}/debian/plexmediaserver_${version}_${debArch}.deb";
        hash = debHash;
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
