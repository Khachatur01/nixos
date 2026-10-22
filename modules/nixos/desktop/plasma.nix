{ lib, ... }:
{
  imports = [ ./common.nix ];

  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # No KWallet: plasma6 enables its PAM module unconditionally, so force it off.
  security.pam.services.login.kwallet.enable = lib.mkForce false;
  security.pam.services.kde.kwallet.enable = lib.mkForce false;

  home-manager.sharedModules = [ ../../home-manager/plasma.nix ];
}
