
  let
    version = "2.0-1311";
    vhash = "sha256-PFo5GtEZ/j5Mu1+42SVLUhXRwsE3CFPoGhBcrktnsHg=";
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
