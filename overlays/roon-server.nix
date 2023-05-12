
  let
    version = "2.0-1272";
    vhash = "sha256-oLHdgOaGnu7hRm863ryf4r05nN8wQL7WKxN3ONG67J4=";
    urlVersion = builtins.replaceStrings [ "." "-" ] [ "00" "0" ] version;
  in
self: super: {

roon-server = super.roon-server.overrideAttrs (old: {
    src = super.fetchurl {
      url = "https://download.roonlabs.com/updates/production/RoonServer_linuxx64_${urlVersion}.tar.bz2";
      hash = vhash;
    };

  });
}
