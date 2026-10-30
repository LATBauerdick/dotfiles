{ pkgs, ... }:

{
  users.users.btal = {
    isNormalUser = true;
    home = "/home/btal";
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
    uid = 501;
    openssh.authorizedKeys.keys = [
    ];
  };

}
