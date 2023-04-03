
  { config, pkgs, lib, ... }:

  let
    user = "bauerdic";
    password = "guest";
    SSID = "1201bgn";
    SSIDpassword = "elefanT1747";
    interface = "wlan0";
    hostname = "LATBpi";
  in {
    # imports = ["${fetchTarball "https://github.com/NixOS/nixos-hardware/archive/936e4649098d6a5e0762058cb7687be1b2d90550.tar.gz" }/raspberry-pi/4"];

    imports = ["${fetchTarball "https://github.com/NixOS/nixos-hardware/archive/1c076b237f3b7b3c178e8672c7c700f295fbdb7e.tar.gz" }/raspberry-pi/4"];
    

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-label/NIXOS_SD";
        fsType = "ext4";
        options = [ "noatime" ];
      };
    };

#    swapDevices = [ { device = "/.swapfile"; size = 1024; } ];

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
    users.users.bauerdic = {
      isNormalUser = true;
      home = "/home/bauerdic";
      extraGroups = [
        "wheel"
  #      "docker"
        "networkmanager"
        "messagebus"
        "systemd-journal"
        "disk"
        "audio"
        "video"
  #      "deluge"
      ];

      shell = pkgs.zsh;
      initialHashedPassword = "";
      uid = 6170;
      openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCz/USADwq6nAEB27lhUi8kM155PoAWrU3UFhd2eqYmJ+MBnYpOpK1GhFznxv5bpYaUS7TW6Am7gDh7EZRzKrf1LSrJeGBZ2R9OCMFH61X/g0gp0Qrs6VXqTe4I+DYmt7znTSa1kx1mg64C9JM4aUFzpxgUYzFiaaqqjZH3Bfm2IuDfT0SOVFmYwV9FD9pPvtb8pYQAhuHRNqFXb0CSW0Ve/CXSPJRfKtcaTTME+Wl1IQBEWBrf8W4xrDT9V2eU1G/UaQv3MYBNimcGyztlpxjpGTILXWaFFxWaCh8ZNvhkCAxWTLs/scZNOWuUUkeQoRsPNu7wYTfC/wb33CjEvvHic0MNtg8umeciYAgJ1hE5/nJ0M0rl5mxLBlJjY2JSzmPOY5nq9L1eWSwXOnnHDzZgBkIPr98wTiRojG45xXDEBKRRXDOqb/qdyiqQj5sOPCZhSBL+kLFRce0aoheacjp5wo4mIftsi3xdW5AY5EnxhSA1tZOfZ9rr9cK5ZPmER7wjV4dKwI7eVIvZ3ai2oqZrQlDR8NoUfES84mVOP+N08/VE+JunZB8FrA4ESghcTaG8ZjTl+5S+6Xh+9Q4IzwEh+dHa8drafgR4atjPr0cg265LV6jR2bPwoWdQvhGw1dwWbiF+HlAozOU07JPO7kyNyl0SkTTROit+La3nkpdMQQ=="
      ];
    };

    boot.loader.raspberryPi.enable = true;
  # Set the version depending on your raspberry pi. 
    boot.loader.raspberryPi.version = 4;
  #  boot.loader.raspberryPi.firmwareConfig = ''
  #    dtparam=audio=on
  #    dtoverlay=dwc2
  #  '';

  #  hardware.raspberry-pi."4".pwm0.enable = true;
    hardware.raspberry-pi."4".dwc2.enable = true;
    boot.kernelModules = [ "dwc2" "libcomposite" ];

# Enable GPU acceleration
    hardware.raspberry-pi."4".fkms-3d.enable = true;

    hardware.pulseaudio.enable = true;

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
ln -s functions/ecm.usb0 configs/c.1/
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
    services.dnsmasq.extraConfig = ''
      interface=usb0
      dhcp-option=3
      leasefile-ro
      dhcp-range=10.55.0.2,10.55.0.6,255.255.255.248,1h
    '';

#    services.xserver = {
#      enable = true;
#      displayManager.lightdm.enable = true;
#      desktopManager.xfce.enable = true;
#    };

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

  }
