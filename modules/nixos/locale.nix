{ lib, ... }:
{
  time.timeZone = lib.mkDefault "Asia/Yerevan";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  console.keyMap = lib.mkDefault "us";

  services.xserver.xkb = {
    layout = lib.mkDefault "us,am,ru";
    variant = lib.mkDefault ",phonetic-alt,";
    options = lib.mkDefault "grp:win_space_toggle";
  };
}
