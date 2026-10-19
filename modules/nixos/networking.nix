{ pkgs, hostname, ... }:
{
  networking = {
    hostName = hostname;
    networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-l2tp
        networkmanager-openvpn
        networkmanager-strongswan
      ];
    };
    firewall.enable = true;
  };
}
