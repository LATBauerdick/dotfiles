
  let
    version = "2.0-1368";
    vhash = "sha256-osyEiefd+Gb7Wfo7mDDeP2QHb2lUTD+dxBzMdsrof0M=";
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
