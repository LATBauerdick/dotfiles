{ pkgs ? import <nixpkgs> {} }:

let
  fonts = pkgs.stdenvNoCC.mkDerivation {
    pname = "myfonts";
    name = "myfonts";
    passthru.tlType = "run";
    src = ../../secret/fonts;
    dontConfigure = true;

    installPhase = ''
      runHook preInstall
      cp -R share $out/
      cp -R tex $out/
      runHook postInstall
    '';

    meta = {
      description = "my fonts, example Adobe Myriad and Monotype Plantin fonts";
    };
  };

  latexFonts = { pkgs = [ fonts ]; };

  postCombineOverride = oldAttrs: {
    postBuild = oldAttrs.postBuild + ''
    #  updmap --sys --enable Map=Myriad.map --enable Map=Plantin.map
      updmap --sys
    '';
  };

  mytexlive = (pkgs.texlive.combine {
    inherit (pkgs.texlive)
      scheme-full;
    inherit latexFonts;
  }).overrideAttrs postCombineOverride;

in
{
  inherit fonts mytexlive;
}
