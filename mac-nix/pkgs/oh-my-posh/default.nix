#
# from https://gitlab.com/ShrykeWindgrace/powershell-modules/-/tree/master/oh-my-posh
{ stdenv, fetchurl, fetchFromGitHub, unzip, sd, lib }:

stdenv.mkDerivation rec {
    pname = "oh-my-posh";
    version = "7.15.0";
    exec = fetchurl {
      url = "https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v${version}/posh-linux-amd64";
      sha256 = "cI6f2P7VzErBZ6SyKpQvKv9O1cr5wCvqOwF+w5bzt1c=";
      executable = true;
    };

    themes = fetchurl {
      url = "https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v${version}/themes.zip";
      sha256 = "ZGxb7gKktWrubmat88SwULLqj+1tgqsT15GVBbuy2nQ=";
    };
    src = fetchFromGitHub
      {
        owner = "JanDeDobbeleer";
        repo = "oh-my-posh";
        rev = "v${version}";
        sha256 = "tbkfcc7zOVJcfgiBFzYnxJ9rznnmPubugIKnT1AQQFQ=";
      } + "/packages/powershell/";


    installPhase = let p = "${pname}/${version}"; in
      ''
        mkdir -p $out/${p}/themes
        mkdir -p $out/${p}/bin
        cp ${exec} $out/${pname}/oh-my-posh
        unzip ${themes} -d $out/${p}/themes
        cp -r * $out/${p}
      '';


    dontBuild = true;
    dontConfigure = true;
    doInstallCheck = false;
    dontStrip = true;
    dontFixup = false;
    fixupPhase = let p = "${pname}/${version}"; in ''sd  "0.0.0.1" "${version}" $out/${p}/oh-my-posh.psd1'';

    buildInputs = [ unzip sd ];
    meta = with lib; {
      description = "oh-my-posh xxx";
      longDescription = ''
oh-my-posh xxx
oh-my-posh xxx
oh-my-posh xxx
      '';
      homepage = "https://xxx.sh/";
      license = licenses.mit;
      platforms = platforms.all;
      maintainers = with maintainers; [ nequissimus ];
    };

}

