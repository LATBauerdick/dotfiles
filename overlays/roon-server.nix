
  let
    version = "2.0-1244";
    vhash = "sha256-godyvkeClBc6AW3WWNYRX+2gqhGWf/Y7xJdX6RfYDn0=";
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
