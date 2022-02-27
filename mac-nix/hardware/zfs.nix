{ config, lib, pkgs, modulesPath, ... }:

{

  fileSystems."/mnt" =
    { device = "z/d";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/mnt/dev" =
    { device = "z/d/dev";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/mnt/zk" =
    { device = "z/d/zk";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/mnt/data" =
    { device = "z/d/data";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/mnt/p2022" =
    { device = "z/d/p2022";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
}
