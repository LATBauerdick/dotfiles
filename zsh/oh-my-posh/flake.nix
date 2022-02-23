{
# based on https://gitlab.com/ShrykeWindgrace/powershell-modules/-/tree/master/oh-my-posh
  description = "install oh-my-posh";

  inputs = let
    version = "7.15.0";
  in {
    pkgs = import <nixpkgs>{};
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    exec = import (builtins.fetchFromGitHub {
      url = "https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v${version}/posh-linux-amd64";
      sha256 = "cI6f2P7VzErBZ6SyKpQvKv9O1cr5wCvqOwF+w5bzt1c=";
      executable = true;
    }) {};
    themes = import (builtins.fetchFromGitHub {
      url = "https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v${version}/themes.zip";
      sha256 = "ZGxb7gKktWrubmat88SwULLqj+1tgqsT15GVBbuy2nQ=";
    }) {};
    src = import (builtins.fetchFromGitHub {
        owner = "JanDeDobbeleer";
        repo = "oh-my-posh";
        rev = "v${version}";
        sha256 = "tbkfcc7zOVJcfgiBFzYnxJ9rznnmPubugIKnT1AQQFQ=";
      }) + "/packages/powershell/";
  };

  outputs = { self, pkgs, nixpkgs, exec,themes,src, flake-utils }: 
    flake-utils.lib.eachDefaultSystem (system:
      let
        packageName = "oh-my-posh";
      in {
        packages.${packageName} = exec;
        defaultPackage = self.packages.${system}.${packageName};

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [ poetry ];
          inputsFrom = builtins.attrValues self.packages.${system};
        };
  oh-my-posh = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "oh-my-posh";
    version = "7.15.0";
    /* exec = pkgs.fetchurl { */
    /*   url = "https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v${version}/posh-linux-amd64"; */
    /*   sha256 = "cI6f2P7VzErBZ6SyKpQvKv9O1cr5wCvqOwF+w5bzt1c="; */
    /*   executable = true; */
    /* }; */



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

    buildInputs = [ pkgs.unzip pkgs.sd ];
  };

  });
}

