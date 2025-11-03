
  let
    version = "2.56.1582";
    urlVersion = builtins.replaceStrings [ "." ] [ "0" ] version;
    vhash = "sha256-LKuno7SpOpxx3JpM36tYlOHjJWWRLRjPiA096Bv/QvQ=";
  in
self: super: {

roon-server = super.roon-server.overrideAttrs (old: {
    src = super.fetchurl {
      url = "https://download.roonlabs.com/updates/production/RoonServer_linuxx64_${urlVersion}.tar.bz2";
      hash = vhash;
    };

  });
}
