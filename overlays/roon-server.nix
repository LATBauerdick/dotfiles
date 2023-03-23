
  let
    version = "2.0-1234";
    vhash = "sha256-644tLtNr3rl3sB3BF0QoiwuIF4tWS8PjehmPKwdpg2k=";
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
