# lmini — Mac mini M4 (Mac16,10), 16 GB, macOS. Always-on home Mac: runs the
# Claude Code workspace, and takes over Deluge from upro (upro is FNAL
# property; decided 2026-09-26).
#
# Per-host split, 2026-09-26: this module started EMPTY, so the first switch to
# darwinConfigurations.lmini activated exactly what m1mac.latb did (checked by
# comparing the two system outPaths). lmini-only settings land here, not in
# darwin/darwin.nix, which the laptops share.
#
# ---- Deluge (2026-09-26) ----
# Storage, set up by hand (volumes are not nix's business, as on the NixOS hosts):
#   /data         APFS (case-sensitive) volume "data" on the internal disk,
#                 fstab: UUID=9EB8EC25-F91B-409A-8C1F-E03B8C270282 /data  ... auto,owners
#   /data/deluge  APFS (case-sensitive) volume "deluge" on the Samsung X5 (USB-C),
#                 fstab: UUID=B3114219-1329-479E-87C5-164F39C0EA59 /data/deluge ... noauto,owners
# Address the internal one by UUID or disk identifier, never by name: the
# startup disk's own volume is called "Data", and name matching is ambiguous.
# The bare mount point /data/deluge on the data volume is root-owned 755, so a
# deluged started while the X5 is missing cannot write there instead of the
# X5 (the upro stub-directory trap of 2026-09-17). NOT 000: the kernel resolves
# ".." of a mounted volume root through the covered directory, so 000 broke
# `ls -la`, `cd ..` and getcwd() inside /data/deluge for every non-root user
# (seen 2026-09-26).
#
# TCC: a launchd daemon running as deluge can write/read/delete on the X5
# volume — probed 2026-09-26 18:21, PASS; no Full Disk Access needed.
#
# Same paths as on upro: config in /data/deluge/.config/deluge, downloads in
# /data/deluge/Downloads — torrents resume without a path rewrite.
# deluged idles until core.conf exists, so this is inert until the migration.
#
# Web UI: http://lmini:8112 . Logs: /Library/Logs/deluge/ .

{ config, pkgs, lib, ... }:
let
  delugeId = 480;   # uid = gid; 400–600 free on lmini except 400, 441, 501
                    # (checked 2026-09-26); upro's NixOS uid 83 is _amavisd here
  delugeVolume = "B3114219-1329-479E-87C5-164F39C0EA59";
  delugeDir = "/data/deluge";
  configDir = "${delugeDir}/.config/deluge";
  logDir = "/Library/Logs/deluge";

  # nixpkgs' deluged does not build on darwin as pinned (checked 2026-09-26):
  #  - standard-pkg-resources pulls in jaraco-path for its TESTS, and
  #    jaraco-path is marked broken on darwin (needs pyobjc): skip those tests
  #  - the headless postInstall rm's share/icons, which darwin never installs
  # Scoped to deluged only, so nothing else on lmini rebuilds. Drop both when
  # nixpkgs fixes them.
  python3Packages = pkgs.python3Packages.overrideScope (pyfinal: pyprev: {
    standard-pkg-resources = pyprev.standard-pkg-resources.overridePythonAttrs (_: {
      doCheck = false;
      nativeCheckInputs = [ ];
    });
  });
  deluged = (pkgs.deluged.override { inherit python3Packages; }).overridePythonAttrs (old: {
    postInstall = builtins.replaceStrings [ "rm -r " ] [ "rm -rf " ] old.postInstall;
  });

  mounted = path: ''/sbin/mount | /usr/bin/grep -q " on ${path} ("'';
in
{
  # (homebrew.onActivation.upgrade = false lived here briefly; since
  # 2026-09-26 it is the shared default in darwin/darwin.nix for every Mac)

  users.knownGroups = [ "deluge" ];
  users.knownUsers = [ "deluge" ];
  users.groups.deluge = {
    gid = delugeId;
    members = [ "latb" ];   # read finished downloads without sudo
    description = "Deluge BitTorrent";
  };
  users.users.deluge = {
    uid = delugeId;
    gid = delugeId;
    home = delugeDir;
    createHome = false;
    shell = "/usr/bin/false";
    isHidden = true;
    description = "Deluge BitTorrent";
  };

  environment.systemPackages = [ deluged ];   # deluge-console for latb

  # Root: wait for /data (fstab, auto), then put the X5 volume on /data/deluge.
  # Re-runs every 5 min, so the volume comes back by itself after a USB dropout.
  launchd.daemons.deluge-mount = {
    script = ''
      for i in $(/usr/bin/seq 60); do ${mounted "/data"} && break; /bin/sleep 5; done
      ${mounted "/data"} || { echo "$(/bin/date) /data not mounted"; exit 1; }
      if ! ${mounted delugeDir}; then
        echo "$(/bin/date) mounting ${delugeVolume} on ${delugeDir}"
        /usr/sbin/diskutil mount -mountPoint ${delugeDir} ${delugeVolume} || exit 1
      fi
      # ownership of the volume root, only ever while it is mounted: never
      # touch the root-owned mount point underneath
      if ${mounted delugeDir}; then
        /usr/sbin/chown deluge:deluge ${delugeDir}
        /bin/chmod 2770 ${delugeDir}
      fi
    '';
    serviceConfig = {
      RunAtLoad = true;
      StartInterval = 300;
      StandardOutPath = "${logDir}/mount.log";
      StandardErrorPath = "${logDir}/mount.log";
    };
  };

  launchd.daemons.deluged = {
    script = ''
      # idle until the volume is up and the config has been migrated
      until [ -r ${configDir}/core.conf ]; do /bin/sleep 30; done
      exec ${deluged}/bin/deluged -d -c ${configDir} -L info
    '';
    serviceConfig = {
      UserName = "deluge";
      GroupName = "deluge";
      Umask = 7;   # 007: group deluge (incl. latb) read/write, others nothing
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "${logDir}/deluged.log";
      StandardErrorPath = "${logDir}/deluged.log";
    };
  };

  launchd.daemons.deluge-web = {
    script = ''
      until [ -r ${configDir}/web.conf ]; do /bin/sleep 30; done
      exec ${deluged}/bin/deluge-web -d -c ${configDir} -p 8112 -L info
    '';
    serviceConfig = {
      UserName = "deluge";
      GroupName = "deluge";
      Umask = 7;
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "${logDir}/deluge-web.log";
      StandardErrorPath = "${logDir}/deluge-web.log";
    };
  };

  # Log directory for the daemons above. preActivation runs before the users
  # and launchd steps, so it exists when the jobs first load; numeric ids,
  # because on the first switch the deluge user does not exist yet.
  system.activationScripts.preActivation.text = ''
    /bin/mkdir -p ${logDir}
    /usr/sbin/chown ${toString delugeId}:${toString delugeId} ${logDir}
    /bin/chmod 0770 ${logDir}
  '';
}
