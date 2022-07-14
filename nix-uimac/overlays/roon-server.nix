
self: super: {

roon-server = super.roon-server.overrideAttrs (old: {
  src =
   let
      version = "1.8-988";
      urlVersion = builtins.replaceStrings [ "." "-" ] [ "00" "00" ] version;
    in
    super.fetchurl {
      url = "http://download.roonlabs.com/builds/RoonServer_linuxx64_${urlVersion}.tar.bz2";
      sha256 = "sha256-e8hSvHKeyJOIp6EWy1JLOWnj6HE2McFk9bw5vVZ96/I=";
    };

  installPhase =
    let
      wrapBin = binPath: ''
        (
          binDir="$(dirname "${binPath}")"
          binName="$(basename "${binPath}")"
          dotnetDir="$out/RoonDotnet"

          ln -sf "$dotnetDir/dotnet" "$dotnetDir/$binName"
          rm "${binPath}"
          makeWrapper "$dotnetDir/$binName" "${binPath}" \
            --add-flags "$binDir/$binName.dll" \
            --argv0 "$binName" \
            --prefix LD_LIBRARY_PATH : "${super.lib.makeLibraryPath [ super.alsa-lib super.icu66 super.ffmpeg super.openssl ]}" \
            --prefix PATH : "$dotnetDir" \
            --prefix PATH : "${super.lib.makeBinPath [ super.alsa-utils super.cifs-utils super.ffmpeg ]}" \
            --run "cd $binDir" \
            --set DOTNET_ROOT "$dotnetDir"
        )
      '';
    in
    ''
      runHook preInstall
      mkdir -p $out
      mv * $out

      rm $out/check.sh
      rm $out/start.sh
      rm $out/VERSION

      ${wrapBin "$out/Appliance/RAATServer"}
      ${wrapBin "$out/Appliance/RoonAppliance"}
      ${wrapBin "$out/Server/RoonServer"}

      mkdir -p $out/bin
      makeWrapper "$out/Server/RoonServer" "$out/bin/RoonServer" --run "cd $out"

      # This is unused and depends on an ancient version of lttng-ust, so we
      # just patch it out
      patchelf --remove-needed liblttng-ust.so.0 $out/RoonDotnet/shared/Microsoft.NETCore.App/6.0.6/libcoreclrtraceptprovider.so

      runHook postInstall
    '';

  });
}

