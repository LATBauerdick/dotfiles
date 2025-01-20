
  let
    version = "2.0-1496";
    vhash = "sha256-QglwnTO7dZ/8X8pNj63D6XQdJmGTKPfOG91xgfqWho0=";
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
