/* This contains various packages we want to overlay. Note that the
 * other ".nix" files in this directory are automatically loaded.
 */
self: super: {
  starship = super.starship.overrideAttrs (old: {
    src = super.fetchFromGitHub {
      repo = "starship";
    };
  });
}

