{ lib, ... }:
{
  boot.loader = {
    systemd-boot.enable = lib.mkDefault true;
    systemd-boot.configurationLimit = lib.mkDefault 5;
    efi.canTouchEfiVariables = lib.mkDefault true;
  };
}
