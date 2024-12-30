# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }@args:
let
  hostname = "nix-latb";
  /* hostId = "28c80f12"; # head -c 8 /etc/machine-id */
  plexEnable = false;
  roonEnable = false;
  roonBridgeEnable = false;
  delugeEnable = false;
  unifiEnable = false;
  nextdnsEnable = false;
  adguardEnable = false;
  tailscaleEnable = true;

  zfsPools = [ ];
in {
  imports =
    [ # Include the results of the hardware scan.
#      ./hardware-configuration.nix
#      ./networking.nix
#      ./wireguard.nix
    ];

  services.tailscale.enable = tailscaleEnable;
  networking.nameservers = [ "100.100.100.100" "8.8.8.8" "1.1.1.1" ];
  networking.search = [ "taild2340b.ts.net" ];

  boot.kernel.sysctl = {
    # if you use ipv4, this is all you need
    "net.ipv4.conf.all.forwarding" = true;

    # If you want to use it for ipv6
    "net.ipv6.conf.all.forwarding" = true;

    /* # source: https://github.com/mdlayher/homelab/blob/master/nixos/routnerr-2/configuration.nix#L52 */
    /* # By default, not automatically configure any IPv6 addresses. */
    /* "net.ipv6.conf.all.accept_ra" = 0; */
    /* "net.ipv6.conf.all.autoconf" = 0; */
    /* "net.ipv6.conf.all.use_tempaddr" = 0; */

    /* # On WAN, allow IPv6 autoconfiguration and tempory address use. */
    /* "net.ipv6.conf.${name}.accept_ra" = 2; */
    /* "net.ipv6.conf.${name}.autoconf" = 1; */
  };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
      wireguard-tools
      sshfs
      mosh
      networkmanager
      cryptsetup
      vim
      bind      # for nslookup  
      mosh
      syncthing
      less
      man
      coreutils
      binutils gcc gnumake openssl
      nix-prefetch-git
  ];

  fonts.packages = [
#    pkgs.cm_unicode
    pkgs.lmodern
  ];

# use unstable nix so we can access flakes
#  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
      experimental-features = nix-command flakes
    '';

#   fileSystems."/mnt/latb-data" =
#    { device = "/dev/disk/by-id/scsi-0HC_Volume_11897569";
#      fsType = "ext4";
#    };

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.devices = [ "/dev/sda" ];


  networking.hostName = "nix-latb"; # Define your hostname.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  # networking.useDHCP = false;
  # networking.interfaces.ens3.useDHCP = true;

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };


  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jane = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  # };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   wget vim
  #   firefox
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  system.stateVersion = "20.09"; # Did you read the comment?




  # Initial empty root password for easy login:
  # users.users.root.initialHashedPassword = "";
  users.users.root.initialPassword = "root";
  services.openssh.settings.PermitRootLogin = "prohibit-password";
  services.openssh.enable = true;

  # Replace this by your SSH pubkey
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJOXZjedCEONef8tQoqk8iZYODg0VoONlyfIz5tFfWXz bauerdic@lmini.local"
  ];

#####################LATB

  boot.kernel.sysctl = {
    # Note that inotify watches consume 1kB on 64-bit machines.
    # needed for syncthing
    "fs.inotify.max_user_watches"   =  204800;   # default:  8192
  #  "fs.inotify.max_user_instances" =    1024;   # default:   128
  #  "fs.inotify.max_queued_events"  =   32768;   # default: 16384
  };

  # services.openssh.gatewayPorts = "yes";
  services.openssh.settings.GatewayPorts = "yes";
  # 8385 for syncthing WebGUI port forward, 838x for my reverse tunnel
  networking.firewall.allowedTCPPorts = [ 8385 8386 8387 8388 8389 8888 8080 32401 ];

#  fileSystems."/data" =
#  { #device = "/dev/disk/by-uuid/9834bc72-2720-4ac1-86e6-2c737db330a0";
#    #fsType = "ext4";
#    options = [ "nofail" ];
#  };
  # Set your time zone.
  time.timeZone = "America/Chicago";
  #
  # Define a user accounts. Don't forget to set a password with ‘passwd’.
  programs.zsh.enable = true;
  users.extraUsers =
  {
    root =
    {
      password = "nixos";
      openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDYAViDcLkA+y6U+Gl9gxzGRGiZVu1B5QaIciRAPbumoH3yGLGzXrrRqRctV1rhf6aX+LISeVQtPbeCSZR054Z2BRZ0VwbPg53hlZ+xnMGLf8pukgWcSryqKw/Tn/58BQTjul4Em7Xc2Mjl+2wNGTh/tFD4ZMgvqB8lR1n/c6dDdRBJRoxyc8Yao2cXhAATtasDZ/YwK/CY97C1OhUxgI9ByTbn2fCsvTDjOHgmRSEGg8fcnHxNgboOsHHygFoI22cbZBe7+NrScXmK0xPVEAmyfIFXsjwx0V5pI5XNB+C19up2x8TXlE/npX5GDuQRgibXUrW163ItsEoVgxLsrOmnLXjGKUTmpCzQ2e6VV8vHIq4gupy2nqO9dMPNM4lP39ZTU5j8NptWXgHIKcMCclj6QYV6sVSKOokjiEp7maN7tQ24ZfxRJjsxUO5HvRuzrgLiKeRdfSiaREdszWT/gPW5tT4FDDmbGwMoKWOMb8BMrwYtnTlUTsPl00Y+cET4mgz7POFEqCzLRat+76Cd2qMVAqWkjv37R08pDMpViKlR6wb8YXPHfgIfyYGmXyDnQwH1AB/jQsSBOprx3e/BD/pGfwrXftQb+hhdg0mWr0WEikf9+SgIm/w1NdWcypHPXCSOQa6wfWjl2Zb8dtlBrd4QkD+hXgn3by9AKHM/INXnWw== iPad" ];
    };
    bauerdic =
    {
       extraGroups = [ "wheel" "networkmanager" ];
       uid = 6170;
       shell = "/run/current-system/sw/bin/zsh";
       isNormalUser = true;
       openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDYAViDcLkA+y6U+Gl9gxzGRGiZVu1B5QaIciRAPbumoH3yGLGzXrrRqRctV1rhf6aX+LISeVQtPbeCSZR054Z2BRZ0VwbPg53hlZ+xnMGLf8pukgWcSryqKw/Tn/58BQTjul4Em7Xc2Mjl+2wNGTh/tFD4ZMgvqB8lR1n/c6dDdRBJRoxyc8Yao2cXhAATtasDZ/YwK/CY97C1OhUxgI9ByTbn2fCsvTDjOHgmRSEGg8fcnHxNgboOsHHygFoI22cbZBe7+NrScXmK0xPVEAmyfIFXsjwx0V5pI5XNB+C19up2x8TXlE/npX5GDuQRgibXUrW163ItsEoVgxLsrOmnLXjGKUTmpCzQ2e6VV8vHIq4gupy2nqO9dMPNM4lP39ZTU5j8NptWXgHIKcMCclj6QYV6sVSKOokjiEp7maN7tQ24ZfxRJjsxUO5HvRuzrgLiKeRdfSiaREdszWT/gPW5tT4FDDmbGwMoKWOMb8BMrwYtnTlUTsPl00Y+cET4mgz7POFEqCzLRat+76Cd2qMVAqWkjv37R08pDMpViKlR6wb8YXPHfgIfyYGmXyDnQwH1AB/jQsSBOprx3e/BD/pGfwrXftQb+hhdg0mWr0WEikf9+SgIm/w1NdWcypHPXCSOQa6wfWjl2Zb8dtlBrd4QkD+hXgn3by9AKHM/INXnWw== iPad"
       ];
    };
  };

  security = {
    sudo.extraRules = [
      { users = [ "bauerdic" ];
        commands = [ { command = "ALL"; options = [ "NOPASSWD" "SETENV" ]; } ];
      }
    ];
  };

  services.syncthing = {
    enable = true;
    dataDir = "/home/bauerdic/";
    user = "bauerdic";
  };

  nix.settings.trusted-users = [ "root" "bauerdic" ];

  # open firewall ports for mosh, wireguard
  networking.firewall.allowedUDPPortRanges = [
    { from = 60001; to = 61000; }
  ];
  programs.mosh.enable = true;

}
