
  let
    version = "2.0-1432";
    vhash = "sha256-h0Ly5S8ML29RtaZOpe0k4U/R0coClHHGUZyu5d1PqzQ=";
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
