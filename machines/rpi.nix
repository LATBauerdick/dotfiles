# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let
    SSID = "1201bgn";
    SSIDpassword = "elefanT1747";
    interface = "wlan0";
    hostname = "lpi";

    rpiHardware = fetchTarball {
          # url=https://github.com/NixOS/nixos-hardware/archive/a6aa174fa61e55bd7e62d35464d3092aefe0421.tar.gz;
          # sha256="14jba7xggr0ghgy6bvq4v34hlafk0nr182s5i0nv3x4xj1hzd13a";
          url=https://github.com/NixOS/nixos-hardware/archive/master.tar.gz;
          sha256="1jc53qv3wlhky0bzcda0fifdx9mky6byycmyb0rrqcn0ys6ws87b";
        };


  roonEnable = false;
in {

  # nixpkgs.config.allowUnfree = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  # networking.useDHCP = false;
  # networking.interfaces.eth0.useDHCP = true;
  # networking.interfaces.usb0.useDHCP = true;
  # networking.interfaces.wlan0.useDHCP = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

	imports = [ "${rpiHardware}/raspberry-pi/4" ];
	hardware = {
	    raspberry-pi."4".apply-overlays-dtmerge.enable = true;
	    # deviceTree = {
	    #   enable = true;
	    #   filter = "*rpi-4-*.dtb";
	    # };
	};
  #  hardware.raspberry-pi."4".pwm0.enable = true;
	hardware.raspberry-pi."4".dwc2.enable = true;

# Enable GPU acceleration
        hardware.raspberry-pi."4".fkms-3d.enable = true;

        hardware.pulseaudio.enable = true;
        # hardware.raspberry-pi."4".audio.enable = true;
        sound.enable = true;

	boot.kernelModules = [ "dwc2" "g_ether" "libcomposite" ];
	console.enable = false;

  # imports = [ "${rpiHardware}/raspberry-pi/4" ];

  fileSystems = {
      "/" = {
        device = "/dev/disk/by-label/NIXOS_SD";
        fsType = "ext4";
        options = [ "noatime" ];
      };
  };
  programs.zsh.enable = true;

#  swapDevices = [ { device = "/.swapfile"; size = 1024; } ];

  networking = {
      hostName = hostname;
      wireless = {
        enable = true;
        networks."${SSID}".psk = SSIDpassword;
        interfaces = [ interface ];
      };
      useDHCP = false;
      interfaces.eth0.useDHCP = true;
  #    interfaces.usb0.useDHCP = true;
      interfaces."${interface}".useDHCP = true;
  };
  services.openssh.enable = true;

  networking.interfaces.usb0.useDHCP = false;
  networking.interfaces.usb0.ipv4.addresses = [ { address = "10.55.0.1"; prefixLength = 29; } ];


  systemd.services.foo = {
      script = ''
set +e
cd /sys/kernel/config/usb_gadget/
mkdir -p pi4
cd pi4
echo 0x1d6b > idVendor # Linux Foundation
echo 0x0104 > idProduct # Multifunction Composite Gadget
echo 0x0100 > bcdDevice # v1.0.0
echo 0x0200 > bcdUSB # USB2
echo 0xEF > bDeviceClass
echo 0x02 > bDeviceSubClass
echo 0x01 > bDeviceProtocol
mkdir -p strings/0x409
echo "fedcba9876543211" > strings/0x409/serialnumber
echo "Ben Hardill" > strings/0x409/manufacturer
echo "PI4 USB Device" > strings/0x409/product
mkdir -p configs/c.1/strings/0x409
echo "Config 1: ECM network" > configs/c.1/strings/0x409/configuration
echo 250 > configs/c.1/MaxPower
# Add functions here
# see gadget configurations below
mkdir -p functions/ecm.usb0
HOST="00:dc:c8:f7:75:14" # "HostPC"
SELF="00:dd:dc:eb:6d:a1" # "BadUSB"
echo $HOST > functions/ecm.usb0/host_addr
echo $SELF > functions/ecm.usb0/dev_addr
ln -sf functions/ecm.usb0 configs/c.1/
# End functions
ls /sys/class/udc > UDC
#udevadm settle -t 5 || :
#ifup usb0
#service dnsmasq restart
#ifconfig usb0 10.0.0.1 netmask 255.255.255.252 up
#route add -net default gw 10.0.0.2
    '';
    wantedBy = [ "multi-user.target" ];
  };


  services.dnsmasq.enable = true;
#  services.dnsmasq.servers = [ "8.8.8.8" "8.8.4.4" ];
  # services.dnsmasq.settings = {
  #   interface = "usb0";
  #   dhcp-option = 3;
  #   leasefile-ro;
  #   dhcp-range = [ "10.55.0.2,10.55.0.6,255.255.255.248,1h" ];
  # };
  services.dnsmasq.extraConfig = ''
    interface=usb0
    dhcp-option=3
    leasefile-ro
    dhcp-range=10.55.0.2,10.55.0.6,255.255.255.248,1h
  '';

#  services.xserver = {
#    enable = true;
#    displayManager.lightdm.enable = true;
#    desktopManager.xfce.enable = true;
#  };

  # use unstable nix so we can access flakes
  nix.package = pkgs.nixUnstable;
  nix.extraOptions = "experimental-features = nix-command flakes";


  time.timeZone = "America/Chicago"; # Set your time zone.

  # Don't require password for sudo
  security.sudo.wheelNeedsPassword = false;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  #  environment.systemPackages = with pkgs; [ hostapd dnsmasq bridge-utils coreutils vim  git tmux ];
  environment.systemPackages = with pkgs; [

	libraspberrypi
	raspberrypi-eeprom
	
      dnsmasq
      coreutils
      gnumake psmisc
      vim  git tmux
  ];

  boot.kernel.sysctl = {
      # Note that inotify watches consume 1kB on 64-bit machines.
      # needed for syncthing
      "fs.inotify.max_user_watches"   =  204800;   # default:  8192
  };
  services.syncthing = {
      enable = true;
      dataDir = "/home/bauerdic/";
      user = "bauerdic";
  };

  programs.mosh.enable = true;

  services.avahi = {
      enable = true;
      nssmdns = true;
      publish = {
        enable = true;
        addresses = true;
        domain = true;
        hinfo = true;
        userServices = true;
        workstation = true;
      };
  };

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "roon-bridge"
      "unrar"
  ];
  services.roon-bridge.enable = roonEnable;
  services.roon-bridge = {
      openFirewall = true;
  };
  services.shairport-sync.enable = true;
  services.shairport-sync.openFirewall = true;
}

