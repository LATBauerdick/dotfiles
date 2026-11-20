
  # Roon Server newer than nixpkgs. Since 2.74 the tarball is self-contained:
  # no shared RoonDotnet/ any more, each of Server/ and Appliance/ ships its own
  # CoreCLR and an apphost (RoonServer.exe, RoonAppliance.exe, RAATServer.exe,
  # aliased via .roonhost/). nixpkgs' installPhase still expects RoonDotnet/, so
  # it is replaced here; autoPatchelfHook + buildInputs are kept from nixpkgs.
  # Bump: version + hash (nix-prefetch-url the URL below, then
  # nix hash convert --hash-algo sha256 --to sri). Latest production version:
  # tar -xjOf RoonServer_linuxx64.tar.bz2 RoonServer/VERSION
  let
    version = "2.75.1725"; # latest production 2026-11-19 (nixpkgs 26.11 has 2.70.1671)
    urlVersion = builtins.replaceStrings [ "." ] [ "0" ] version;
    vhash = "sha256-V2ewKGZTyc47mzsL1SG93tkBluKkJvEr/nSNxV6iIgk=";
  in
self: super: {

roon-server = super.roon-server.overrideAttrs (old: {
    inherit version;
    src = super.fetchurl {
      url = "https://download.roonlabs.com/updates/production/RoonServer_linuxx64_${urlVersion}.tar.bz2";
      hash = vhash;
    };

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      mv * $out
      rm $out/check.sh $out/check-common.sh $out/start.sh

      # libraries the runtime dlopens (globalization, TLS, GSSAPI, audio)
      mkdir -p $out/bin
      makeWrapper "$out/Server/RoonServer" "$out/bin/RoonServer" \
        --chdir "$out" \
        --prefix LD_LIBRARY_PATH : "${super.lib.makeLibraryPath (with super; [ alsa-lib icu66 ffmpeg openssl krb5 ])}" \
        --prefix PATH : "${super.lib.makeBinPath (with super; [ alsa-utils cifs-utils ffmpeg coreutils procps gnugrep gawk ])}"
      runHook postInstall
    '';
  });
}
