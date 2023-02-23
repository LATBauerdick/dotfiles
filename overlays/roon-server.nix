
  let
    version = "2.0-1202";
    vhash = "sha256-YeBzXnw/BpJDUJ7fUf7TH0zQcpCjUm9peB7zPO2ZsYI=";
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
