
  let
    version = "2.0-1365";
    vhash = "sha256-RwmBszv3zCFX8IvDu/XMVu92EH/yd1tyaw0P4CmODCA=";
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
