
{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.wireguard-tools ];

  networking.wg-quick.interfaces.wg0 = {
    autostart = true;

    address = [ "10.77.0.3/24" ];

    privateKeyFile = "/var/lib/wireguard/rogstrix.key";
    generatePrivateKeyFile = true;

    peers = [
      {
        publicKey = "jKKKOV2fm5p38QmRHyOw4IcLwrvot3CY0DXd8DMOsw8=";
        endpoint = "156.67.25.2:51820";
        allowedIPs = [ "10.77.0.0/24" ];
        persistentKeepalive = 25;
      }
    ];
  };
}
