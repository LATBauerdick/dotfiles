
self: super: {

slimserver = super.slimserver.overrideAttrs (old: {
  src = super.fetchFromGitHub {
      owner = "Logitech";
      repo = "slimserver";
      rev = "8.3.0";
      hash = "sha256-IEEa5bI5dFFVRUMUn8fwOtIGKDxHtX539BmixhncIHM=";
    };
  });
}


