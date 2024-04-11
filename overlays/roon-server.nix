
  let
    version = "2.0-1392";
    vhash = "sha256-S6p2xlWa1Xgp+umRx1KCs4g1u7JZTByNBNUSJBQweUs=";
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
