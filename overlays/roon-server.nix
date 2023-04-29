
  let
    version = "2.0-1259";
    vhash = "sha256-nd0dDiiUmwhuVivB78EXdj6LrK0ufdSrVYH/0Y++img=";
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
