{ pkgs, ... }:

{
  users.users.bauerdic = {
    isNormalUser = true;
    home = "/home/bauerdic";
    extraGroups = [
      "wheel"
      "docker"
      "networkmanager"
      "messagebus"
      "systemd-journal"
      "disk"
      "audio"
      "video"
      "deluge"
    ];

    shell = pkgs.zsh;
    initialHashedPassword = "";
    uid = 6170;
    openssh.authorizedKeys.keys = [
    ];
  };
}
