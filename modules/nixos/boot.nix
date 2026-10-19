{ lib, ... }:
{
  boot.loader = {
    systemd-boot.enable = lib.mkDefault true;
    systemd-boot.configurationLimit = lib.mkDefault 10;
    efi.canTouchEfiVariables = lib.mkDefault true;
  };
}
