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
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCz/USADwq6nAEB27lhUi8kM155PoAWrU3UFhd2eqYmJ+MBnYpOpK1GhFznxv5bpYaUS7TW6Am7gDh7EZRzKrf1LSrJeGBZ2R9OCMFH61X/g0gp0Qrs6VXqTe4I+DYmt7znTSa1kx1mg64C9JM4aUFzpxgUYzFiaaqqjZH3Bfm2IuDfT0SOVFmYwV9FD9pPvtb8pYQAhuHRNqFXb0CSW0Ve/CXSPJRfKtcaTTME+Wl1IQBEWBrf8W4xrDT9V2eU1G/UaQv3MYBNimcGyztlpxjpGTILXWaFFxWaCh8ZNvhkCAxWTLs/scZNOWuUUkeQoRsPNu7wYTfC/wb33CjEvvHic0MNtg8umeciYAgJ1hE5/nJ0M0rl5mxLBlJjY2JSzmPOY5nq9L1eWSwXOnnHDzZgBkIPr98wTiRojG45xXDEBKRRXDOqb/qdyiqQj5sOPCZhSBL+kLFRce0aoheacjp5wo4mIftsi3xdW5AY5EnxhSA1tZOfZ9rr9cK5ZPmER7wjV4dKwI7eVIvZ3ai2oqZrQlDR8NoUfES84mVOP+N08/VE+JunZB8FrA4ESghcTaG8ZjTl+5S+6Xh+9Q4IzwEh+dHa8drafgR4atjPr0cg265LV6jR2bPwoWdQvhGw1dwWbiF+HlAozOU07JPO7kyNyl0SkTTROit+La3nkpdMQQ=="
    ];
  };
}
