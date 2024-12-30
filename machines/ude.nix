# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }@args:
let
  hostname = "ude";
  /* hostId = "28c80f12"; # head -c 8 /etc/machine-id */
  plexEnable = false;
  roonEnable = false;
  roonBridgeEnable = false;
  delugeEnable = false;
  unifiEnable = false;
  nextdnsEnable = false;
  adguardEnable = false;
  tailscaleEnable = true;
  tailnetName = "taild2340b.ts.net";

  zfsPools = [ ];
in {
  imports =
    [ # Include the results of the hardware scan.
#      ./hardware-configuration.nix
#      ./wireguard.nix
    ];

  system.stateVersion = "20.09"; # Did you read the comment?
# use unstable nix so we can access flakes
#  nix.package = pkgs.nixUnstable;
  nix.settings.trusted-users = [ "root" "latb" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # nix.extraOptions = ''
  #     experimental-features = nix-command flakes
  #   '';

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.devices = [ "/dev/sda" ];

  networking = {
    useDHCP = false;
    hostName = hostname;
    # hostId = hostId;
    nameservers = [ "100.100.100.100" "8.8.8.8" "1.1.1.1" ];
    search = [ tailnetName ];
    interfaces.ens3.useDHCP = true;

    nat = {
      enable = true;
      externalInterface = "ens3";
      internalInterfaces = [ "wg0" ];
    };

    wireguard.interfaces.wg0 = {
      ips = [ "10.0.0.1/24" ];
      listenPort = 60990;
      privateKeyFile = "/etc/nixos/wg-priv";

# This allows the wireguard server to route your traffic to the internet
# you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o ens3 -j MASQUERADE
      '';
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.0.0.0/24 -o ens3 -j MASQUERADE
      '';

      peers = [
        {
          publicKey = "BOiWgg6uuKUm3+tnPdcvIp7LffxQjcoIaMZHbcuCsx8=";
          allowedIPs = [ "10.0.0.0/24" "10.0.0.2/32" ];
          persistentKeepalive = 25;
        }
        {
          publicKey = "/xz3AXSHjuvNNDPxmvMWJIBNoTcEatfBldaS01EV1DM=";
          allowedIPs = [ "10.0.0.3/32" ];
          persistentKeepalive = 25;
        }
        {
          publicKey = "bG6Ro8DiV144lGRGY0YLbasEyXDjkdl3GfZc7XVfm0c=";
          allowedIPs = [ "10.0.0.4/32" ];
          persistentKeepalive = 25;
        }
      ];

    };

    firewall.enable = true;
    firewall.allowPing = true;
    firewall.checkReversePath = "loose";
  # ports for autossh
    firewall.allowedTCPPorts = [ 8385 8386 8387 8388 8389 8888 8080 32401 ];
  # open firewall ports for mosh, wireguard
    firewall.allowedUDPPortRanges = [ { from = 60001; to = 61000; } ];
  };

  services.tailscale.enable = tailscaleEnable;
  services.tailscale.useRoutingFeatures = "server";
# make sure tailscale starts with exit-node enabled
  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";

    # make sure tailscale is running before trying to connect to tailscale
    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];

    # set this service as a oneshot job
    serviceConfig.Type = "oneshot";

    # have the job run this shell script
    script = with pkgs; ''
      # wait for tailscaled to settle
      sleep 2

      # otherwise authenticate with tailscale
      ${tailscale}/bin/tailscale up --advertise-exit-node --accept-routes
    '';
  };

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;

    /* # source: https://github.com/mdlayher/homelab/blob/master/nixos/routnerr-2/configuration.nix#L52 */
    /* # By default, not automatically configure any IPv6 addresses. */
    /* "net.ipv6.conf.all.accept_ra" = 0; */
    /* "net.ipv6.conf.all.autoconf" = 0; */
    /* "net.ipv6.conf.all.use_tempaddr" = 0; */

# On WAN, allow IPv6 autoconfiguration and tempory address use.
    "net.ipv6.conf.ens3.accept_ra" = 2;
    "net.ipv6.conf.ens3.autoconf" = 1;
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnsupportedSystem = true;

  environment.systemPackages = with pkgs; [
      silver-searcher
      wireguard-tools
      sshfs
      mosh
      networkmanager
      cryptsetup
    git
    gnumake
      bind      # for nslookup  
      mosh
      syncthing
      less
      man
      coreutils
    vim
    neovim
    curl
  # To make SMB mounting easier on the command line
    cifs-utils
      binutils gcc gnumake openssl
      nix-prefetch-git
  ];

  fonts.fontDir.enable = true;
  fonts.enableDefaultPackages = true;
  # fonts.enableGhostscriptFonts = true;
  fonts.packages = with pkgs; [
#    (nerdfonts.override { fonts = [ "Iosevka" "Lekton" ]; })
#    cm_unicode
    lmodern
  ];

  programs.zsh.enable = true;

  security = {
    sudo.wheelNeedsPassword = false;
    sudo.extraRules = [
      { users = [ "latb" ];
        commands = [ { command = "ALL"; options = [ "NOPASSWD" "SETENV" ]; } ];
      }
    ];
  };

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "prohibit-password";
  services.openssh.settings.X11Forwarding = true;
  services.openssh.settings.GatewayPorts = "yes";

  programs.mosh.enable = true;

  users.users.root.initialPassword = "root";
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJOXZjedCEONef8tQoqk8iZYODg0VoONlyfIz5tFfWXz latb@lmini.local"
  ];

  time.timeZone = "America/Chicago";

  i18n.defaultLocale = "en_US.UTF-8";

  services.syncthing = {
    enable = true;
    dataDir = "/home/latb/";
    user = "latb";
  };
  boot.kernel.sysctl = {
    # Note that inotify watches consume 1kB on 64-bit machines.
    # needed for syncthing
    "fs.inotify.max_user_watches"   =  204800;   # default:  8192
  #  "fs.inotify.max_user_instances" =    1024;   # default:   128
  #  "fs.inotify.max_queued_events"  =   32768;   # default: 16384
  };

#   fileSystems."/mnt/latb-data" =
#    { device = "/dev/disk/by-id/scsi-0HC_Volume_11897569";
#      fsType = "ext4";
#    };

#  fileSystems."/data" =
#  { #device = "/dev/disk/by-uuid/9834bc72-2720-4ac1-86e6-2c737db330a0";
#    #fsType = "ext4";
#    options = [ "nofail" ];
#  };

}
