{ lib, ... }:
{
  time.timeZone = lib.mkDefault "Asia/Yerevan";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  # en_GB week starts Monday; keeps $ currency and comma thousands separator
  # from the base en_US locale since only LC_TIME is overridden.
  i18n.extraLocaleSettings = lib.mkDefault {
    LC_TIME = "en_GB.UTF-8";
  };
  i18n.supportedLocales = lib.mkDefault [
    "en_US.UTF-8/UTF-8"
    "en_GB.UTF-8/UTF-8"
  ];
  console.keyMap = lib.mkDefault "us";

  services.xserver.xkb = {
    layout = lib.mkDefault "us,am,ru";
    variant = lib.mkDefault ",phonetic-alt,";
    options = lib.mkDefault "grp:win_space_toggle";
  };
}
