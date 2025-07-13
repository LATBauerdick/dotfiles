
  let
    version = "2.53.1544";
    urlVersion = builtins.replaceStrings [ "." ] [ "0" ] version;
    vhash = "sha256-Hbe2EfBbpA3Xzyh4ZYjm1G8qrwg+dEq5YAwZEG59ClI=";
  in
self: super: {

roon-server = super.roon-server.overrideAttrs (old: {
    src = super.fetchurl {
      url = "https://download.roonlabs.com/updates/production/RoonServer_linuxx64_${urlVersion}.tar.bz2";
      hash = vhash;
    };

  });
}
