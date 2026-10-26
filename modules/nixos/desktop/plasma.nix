{
  lib,
  pkgs,
  hostname,
  ...
}:
let
  rdpPort = 3389;
  rdpCertificate = "%h/.local/share/krdpserver/krdp.crt";
  rdpCertificateKey = "%h/.local/share/krdpserver/krdp.key";

  # Keep in sync with the wg0 address in modules/nixos/wireguard.nix.
  vpnAddress = "10.77.0.3";

  # The KCM generates certificates that expire after one day. Replace them with
  # a long-lived self-signed certificate so remote clients don't reject them.
  ensureRdpCertificate = pkgs.writeShellScript "ensure-krdp-certificate" ''
    set -eu

    cert="$HOME/.local/share/krdpserver/krdp.crt"
    key="$HOME/.local/share/krdpserver/krdp.key"

    if [ -s "$cert" ] && [ -s "$key" ] \
      && ${pkgs.openssl}/bin/openssl x509 -checkend 2592000 -noout -in "$cert" >/dev/null 2>&1; then
      exit 0
    fi

    install -d -m 0700 "$(dirname "$cert")"
    tmpdir="$(mktemp -d "$(dirname "$cert")/.cert.XXXXXX")"
    trap 'rm -rf "$tmpdir"' EXIT

    ${pkgs.openssl}/bin/openssl req -x509 -newkey rsa:2048 -sha256 -nodes \
      -days 3650 \
      -subj "/CN=${hostname}" \
      -addext "subjectAltName=DNS:${hostname},IP:${vpnAddress}" \
      -addext "basicConstraints=critical,CA:FALSE" \
      -addext "keyUsage=critical,digitalSignature,keyEncipherment" \
      -addext "extendedKeyUsage=serverAuth" \
      -keyout "$tmpdir/krdp.key" \
      -out "$tmpdir/krdp.crt" >/dev/null 2>&1

    chmod 0600 "$tmpdir/krdp.key"
    chmod 0644 "$tmpdir/krdp.crt"
    mv "$tmpdir/krdp.key" "$key"
    mv "$tmpdir/krdp.crt" "$cert"
  '';
in
{
  imports = [ ./common.nix ];

  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # Plasma's RDP server (KRDP) is a per-user service. Start it with the Plasma
  # session and only expose it on the WireGuard interface.
  systemd.user.services."app-org.kde.krdpserver" = {
    description = "KRDP Server";
    after = [
      "plasma-xdg-desktop-portal-kde.service"
      "plasma-core.target"
    ];
    wantedBy = [ "plasma-workspace.target" ];
    path = [
      pkgs.coreutils
      pkgs.openssl
    ];
    serviceConfig = {
      Type = "exec";
      ExecStartPre = "${ensureRdpCertificate}";
      ExecStart = "${pkgs.kdePackages.krdp}/bin/krdpserver --port ${toString rdpPort} --certificate ${rdpCertificate} --certificate-key ${rdpCertificateKey}";
      Restart = "on-abnormal";
    };
  };

  networking.firewall.interfaces.wg0.allowedTCPPorts = [ rdpPort ];

  # No KWallet: plasma6 enables its PAM module unconditionally, so force it off.
  security.pam.services.login.kwallet.enable = lib.mkForce false;
  security.pam.services.kde.kwallet.enable = lib.mkForce false;

  home-manager.sharedModules = [ ../../home-manager/plasma.nix ];
}
