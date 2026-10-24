
{ pkgs, ... }:

let
  privateKeyFile = "/var/lib/wireguard/rogstrix.key";
  profileName = "Ephen VPN";
  serverPublicKey = "jKKKOV2fm5p38QmRHyOw4IcLwrvot3CY0DXd8DMOsw8=";
in
{
  environment.systemPackages = [
    pkgs.wireguard-tools
  ];

  # Generate a persistent private key outside the Nix store.
  # Keep the existing key across rebuilds and reboots.
  systemd.services.wireguard-keygen = {
    description = "Generate persistent WireGuard client key";

    before = [ "NetworkManager.service" ];
    requiredBy = [ "NetworkManager.service" ];

    path = [
      pkgs.coreutils
      pkgs.wireguard-tools
    ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      install -d -m 0700 /var/lib/wireguard

      if [ ! -s "${privateKeyFile}" ]; then
        umask 077
        wg genkey > "${privateKeyFile}"
      fi

      chmod 0600 "${privateKeyFile}"
    '';
  };

  # Declarative NetworkManager profile.
  networking.networkmanager.ensureProfiles.profiles.${profileName} = {
    connection = {
      id = profileName;
      type = "wireguard";
      interface-name = "wg0";
      autoconnect = true;
      permissions = "";
    };

    wireguard = {
      # The secret agent reads the private key from privateKeyFile.
      # Do not place the actual private key in the Nix configuration.
      private-key-flags = 1;
    };

    # NetworkManager keyfile syntax for a WireGuard peer.
    "wireguard-peer.${serverPublicKey}" = {
      endpoint = "156.67.25.2:51820";
      allowed-ips = "10.77.0.0/24;";
      persistent-keepalive = 25;
    };

    ipv4 = {
      address1 = "10.77.0.3/24";
      method = "manual";
    };

    ipv6.method = "disabled";
  };

  # Supply the private key to NetworkManager from the runtime file.
  networking.networkmanager.ensureProfiles.secrets.entries = [
    {
      file = privateKeyFile;
      key = "private-key";
      matchId = profileName;
      matchSetting = "wireguard";
      matchType = "wireguard";
    }
  ];

  # Permit incoming SSH only through the WireGuard interface.
  services.openssh.enable = true;
  networking.firewall.interfaces.wg0.allowedTCPPorts = [ 22 ];
}
