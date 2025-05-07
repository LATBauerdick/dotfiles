
  let
    version = "2.50.1528";
    urlVersion = builtins.replaceStrings [ "." ] [ "0" ] version;
    vhash = "sha256-8Dxxjj/5JSuXeTxTV2l37ZAmf6BDdhykPSinmgZeEVY=";
  in
self: super: {

roon-server = super.roon-server.overrideAttrs (old: {
    src = super.fetchurl {
      url = "https://download.roonlabs.com/updates/production/RoonServer_linuxx64_${urlVersion}.tar.bz2";
      hash = vhash;
    };

  });
}
