{ pkgs, ... }:

let
  privateKeyFile = "/var/lib/wireguard/rogstrix.key";
  profileName = "Ephen VPN";
  profileUuid = "f7df7904-7b65-3f1c-b9e0-6a84f3cd35c3";
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

    wantedBy = [ "multi-user.target" ];
    requiredBy = [ "NetworkManager.service" ];
    before = [
      "NetworkManager.service"
      "nm-file-secret-agent.service"
    ];

    path = [
      pkgs.coreutils
      pkgs.wireguard-tools
    ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      UMask = "0077";
    };

    script = ''
      install -d -m 0700 /var/lib/wireguard

      if [ ! -s "${privateKeyFile}" ]; then
        tmp="$(mktemp "${privateKeyFile}.XXXXXX")"
        wg genkey > "$tmp"
        mv "$tmp" "${privateKeyFile}"
      fi

      chmod 0600 "${privateKeyFile}"
    '';
  };

  # Declarative NetworkManager profile.
  networking.networkmanager.ensureProfiles.profiles.${profileName} = {
    connection = {
      id = profileName;
      uuid = profileUuid;
      type = "wireguard";
      interface-name = "wg0";
      autoconnect = true;
      # Retry forever. At boot NetworkManager may start before the profile has
      # been imported or the secret agent is ready.
      autoconnect-retries = 0;
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
      matchUuid = profileUuid;
      matchSetting = "wireguard";
      matchType = "wireguard";
    }
  ];

  # The agent reads and validates all secret files when it starts, so the key
  # must exist first. It must also be registered before the declarative
  # profile is imported, otherwise NetworkManager asks for a secret while no
  # agent is connected to D-Bus yet.
  systemd.services.nm-file-secret-agent = {
    requires = [ "wireguard-keygen.service" ];
    after = [ "wireguard-keygen.service" ];
    before = [ "NetworkManager-ensure-profiles.service" ];
  };

  systemd.services.NetworkManager-ensure-profiles = {
    requires = [ "nm-file-secret-agent.service" ];
    after = [ "nm-file-secret-agent.service" ];
  };

  # Permit incoming SSH only through the WireGuard interface.
  services.openssh.enable = true;
  networking.firewall.interfaces.wg0.allowedTCPPorts = [ 22 ];
}
