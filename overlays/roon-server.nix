
  let
    version = "2.0-1470";
    vhash = "sha256-esaxrSdvl1qUNfotOSs8Tj/AUg6hFpl23DGbji/uFO8=";
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
