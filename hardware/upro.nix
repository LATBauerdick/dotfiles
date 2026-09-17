# PLACEHOLDER — replace with the file nixos-generate-config produces during the
# upro install (Phase 4 of the plan: mount root + ESP, nixos-generate-config
# --root /mnt, then copy /mnt/etc/nixos/hardware-configuration.nix here).
# The root entry below (by-label) matches the planned mkfs.ext4 -L nixos and
# will survive the swap; the /boot partuuid MUST come from the generated file
# (the Asahi installer creates the ESP, its partuuid is unknown until then).
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  fileSystems."/" =
    { device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-partuuid/REPLACE-WITH-GENERATED-PARTUUID";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
