
  let
    version = "2.0-1490";
    vhash = "sha256-WZCSBb7BJWMtfB5zeN0/FNQ4uUYpa79YLSzpLlliWlw=";
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
