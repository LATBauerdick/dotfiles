{config, pkgs, ...}: 
{
  config.networking.nat = {
    enable = true;
    externalInterface = "ens3";
    internalInterfaces = [ "wg0" ];
  };

  config.networking.wireguard.interfaces.wg0 = {
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
# other routing options
#  iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o ens3 -j SNAT --to-source 116.203.126.183
#  iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -j MASQUERADE
# port forwarding: make tcp service running on a client at 10.0.0.2:48000 accessible from the internet at 116.203.126.183:45000
#  iptables -t NAT -A PREROUTING -d 116.203.126.183/32 -i ens3 -p tcp -m tcp --dport 45000 -j DNAT --to-destination 10.0.0.2:48000
# A nginx reverse proxy may also be used as an alternative with the proxy_pass directive.

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
}

