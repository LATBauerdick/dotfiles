{ pkgs, ... }:

{
  # terminfo for the terminal latb sshes in from, so TERM=xterm-ghostty is
  # known system-wide (root included) and backspace/delete/colors work.
  # The terminfo output is a separate store path; the cache serves it
  # without building ghostty itself.
  environment.systemPackages = [ pkgs.ghostty.terminfo ];

  # OpenSSH client with GSSAPI/Kerberos. The default build knows the GSSAPI
  # keywords but rejects them ("Unsupported option" on every ssh call, from the
  # Fermilab blocks in the shared ~/.ssh/config), and IgnoreUnknown does not
  # cover known-but-unsupported keywords. With this build the lines are real:
  # kinit, then ssh to *.fnal.gov works from the NixOS hosts too. Cached.
  programs.ssh.package = pkgs.openssh_gssapi;

  users.users.latb = {
    isNormalUser = true;
    home = "/home/latb";
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
