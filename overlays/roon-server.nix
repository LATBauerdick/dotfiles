
  let
    version = "2.0-1483";
    vhash = "sha256-y8MYiWlc3HfF7a3n7yrs84H/9KbEoANd8+7t2ORIm6w=";
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
