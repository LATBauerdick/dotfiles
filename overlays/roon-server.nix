
  let
    version = "2.54.1554";
    urlVersion = builtins.replaceStrings [ "." ] [ "0" ] version;
    vhash = "sha256-tE+WhsXJn1fVkD8wCuu5ZVaBDwsm9hss2KA0nocME+E=";
  in
self: super: {

roon-server = super.roon-server.overrideAttrs (old: {
    src = super.fetchurl {
      url = "https://download.roonlabs.com/updates/production/RoonServer_linuxx64_${urlVersion}.tar.bz2";
      hash = vhash;
    };

  });
}
