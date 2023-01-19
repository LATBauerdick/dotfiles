
  let
    version = "2.0-1193";
    vhash = "sha256-yvM4mEFBelT8Nox0vzI4tlQbxDUkoMAB6q8l5LW8+b4=";
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
