
# { stdenv }:
let
    # host = stdenv.hostPlatform.system;
    host = "aarch64-linux";
    # version = "1.8-1125";
    # urlVersion = builtins.replaceStrings [ "." "-" ] [ "00" "0" ] version;
    system = if host == "x86_64-linux" then "linuxx64"
              else if host == "aarch64-linux" then "linuxarmv8"
              else throw "Unsupported platform ${host}";
    vhash = if system == "linuxx64"
                then "sha256-DbtKPFEz2WIoKTxP+zoehzz+BjfsLZ2ZQk/FMh+zFBM="
            else if system == "linuxarmv8"
                then "sha256-+przEj96R+f1z4ewETFarF4oY6tT2VW/ukSTgUBLiYk="
            else throw "Unsupported platform ${host}";
in
self: super: {

roon-bridge = super.roon-bridge.overrideAttrs (old: {
    src = super.fetchurl {
      url = "https://download.roonlabs.net/builds/RoonBridge_${system}.tar.bz2";
      hash = vhash;
    };

  });
}
