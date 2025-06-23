
  let
    version = "2.52.1538";
    urlVersion = builtins.replaceStrings [ "." ] [ "0" ] version;
    vhash = "sha256-pWg1Cp8aNdR/hoVZDF3kUznJtYsjJYX9J4g1xbmn/lg=";
  in
self: super: {

roon-server = super.roon-server.overrideAttrs (old: {
    src = super.fetchurl {
      url = "https://download.roonlabs.com/updates/production/RoonServer_linuxx64_${urlVersion}.tar.bz2";
      hash = vhash;
    };

  });
}
