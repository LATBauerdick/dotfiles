
  let
    version = "2.0-1223";
    vhash = "sha256-1jHNHj1tB80/CdE7GPCgRsI0+2Gfx4kiE6a0EOI/K5U=";
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
