{ pkgs, ... }:

let
  privateKeyFile = "/var/lib/wireguard/rogstrix.key";
  envFile = "/var/lib/wireguard/rogstrix.env";
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

      # Env file for ensureProfiles substitution (see below).
      printf 'WG_PRIVATE_KEY=%s\n' "$(cat "${privateKeyFile}")" > "${envFile}"
      chmod 0600 "${envFile}"
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
      # Substituted at activation from envFile. Stored in the NM profile
      # (not agent-owned) so manual connects from the Plasma applet work:
      # NM does not query the root-run file secret agent for user-initiated
      # activations. Do not place the actual key in the Nix configuration.
      private-key = "$WG_PRIVATE_KEY";
      private-key-flags = 0;
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

  # Supply the private key to the profile from the runtime env file.
  networking.networkmanager.ensureProfiles.environmentFiles = [ envFile ];

  # The env file must exist before the profile is imported.
  systemd.services.NetworkManager-ensure-profiles = {
    requires = [ "wireguard-keygen.service" ];
    after = [ "wireguard-keygen.service" ];
  };

  # Permit incoming SSH only through the WireGuard interface. openssh opens
  # port 22 on every interface by default, so disable that and rely on the
  # interface-specific rule below.
  services.openssh = {
    enable = true;
    openFirewall = false;
  };
  networking.firewall.interfaces.wg0.allowedTCPPorts = [ 22 ];
}
