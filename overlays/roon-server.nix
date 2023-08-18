
  let
    version = "2.0-1303";
    vhash = "sha256-8KDQroXopeDDv2hV9V7eZUVE9wkv8QoUac2rlLW3b5I=";
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
