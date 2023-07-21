
  let
    version = "2.0-1299";
    vhash = "sha256-2qMW4wX5JfAyRTqMjspegmaMXrxq5VaJTvP2qEtnsbE=";
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
