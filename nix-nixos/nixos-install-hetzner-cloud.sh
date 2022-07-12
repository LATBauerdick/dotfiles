#! /usr/bin/env bash

# Script to install NixOS from the Hetzner Cloud NixOS bootable ISO image.
# (tested with Hetzner's `NixOS 20.03 (amd64/minimal)` ISO image).
# 
# This script wipes the disk of the server!
#
# Instructions:
#
# 1. Mount the above mentioned ISO image from the Hetzner Cloud GUI
#    and reboot the server into it; do not run the default system (e.g. Ubuntu).
# 2. To be able to SSH straight in (recommended), you must replace hardcoded pubkey
#    further down in the section labelled "Replace this by your SSH pubkey" by you own,
#    and host the modified script way under a URL of your choosing
#    (e.g. gist.github.com with git.io as URL shortener service).
# 3. Run on the server:
#
#       # Replace this URL by your own that has your pubkey in
#       curl -L https://raw.githubusercontent.com/nix-community/nixos-install-scripts/master/hosters/hetzner-cloud/nixos-install-hetzner-cloud.sh | sudo bash
# 4. Unmount the ISO image from the Hetzner Cloud GUI.
# 5. Reboot.
#
# To run it from the Hetzner Cloud web terminal without typing it down,
# you can either select it and then middle-click onto the web terminal, (that pastes
# to it), or use `xdotool` (you have e.g. 3 seconds to focus the window):
#
#     sleep 3 && xdotool type --delay 50 'curl YOUR_URL_HERE | sudo bash'
#
# (In the xdotool invocation you may have to replace chars so that
# the right chars appear on the US-English keyboard.)
#
# If you do not replace the pubkey, you'll be running with my pubkey, but you can
# change it afterwards by logging in via the Hetzner Cloud web terminal as `root`
# with empty password.

set -e

# Hetzner Cloud OS images grow the root partition to the size of the local
# disk on first boot. In case the NixOS live ISO is booted immediately on
# first powerup, that does not happen. Thus we need to grow the partition
# by deleting and re-creating it.
sgdisk -d 1 /dev/sda
sgdisk -N 1 /dev/sda
partprobe /dev/sda

mkfs.ext4 -F /dev/sda1 # wipes all data!

mount /dev/sda1 /mnt

nixos-generate-config --root /mnt

# Delete trailing `}` from `configuration.nix` so that we can append more to it.
sed -i -E 's:^\}\s*$::g' /mnt/etc/nixos/configuration.nix

# Extend/override default `configuration.nix`:
echo '
  boot.loader.grub.devices = [ "/dev/sda" ];

  # Initial empty root password for easy login:
  users.users.root.initialHashedPassword = "";
  services.openssh.permitRootLogin = "prohibit-password";

  services.openssh.enable = true;

  # Replace this by your SSH pubkey
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDYAViDcLkA+y6U+Gl9gxzGRGiZVu1B5QaIciRAPbumoH3yGLGzXrrRqRctV1rhf6aX+LISeVQtPbeCSZR054Z2BRZ0VwbPg53hlZ+xnMGLf8pukgWcSryqKw/Tn/58BQTjul4Em7Xc2Mjl+2wNGTh/tFD4ZMgvqB8lR1n/c6dDdRBJRoxyc8Yao2cXhAATtasDZ/YwK/CY97C1OhUxgI9ByTbn2fCsvTDjOHgmRSEGg8fcnHxNgboOsHHygFoI22cbZBe7+NrScXmK0xPVEAmyfIFXsjwx0V5pI5XNB+C19up2x8TXlE/npX5GDuQRgibXUrW163ItsEoVgxLsrOmnLXjGKUTmpCzQ2e6VV8vHIq4gupy2nqO9dMPNM4lP39ZTU5j8NptWXgHIKcMCclj6QYV6sVSKOokjiEp7maN7tQ24ZfxRJjsxUO5HvRuzrgLiKeRdfSiaREdszWT/gPW5tT4FDDmbGwMoKWOMb8BMrwYtnTlUTsPl00Y+cET4mgz7POFEqCzLRat+76Cd2qMVAqWkjv37R08pDMpViKlR6wb8YXPHfgIfyYGmXyDnQwH1AB/jQsSBOprx3e/BD/pGfwrXftQb+hhdg0mWr0WEikf9+SgIm/w1NdWcypHPXCSOQa6wfWjl2Zb8dtlBrd4QkD+hXgn3by9AKHM/INXnWw=="
  ];
}
' >> /mnt/etc/nixos/configuration.nix

nixos-install --no-root-passwd

reboot
