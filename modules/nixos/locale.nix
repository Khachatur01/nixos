{ lib, ... }:
{
  time.timeZone = lib.mkDefault "Asia/Yerevan";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  console.keyMap = lib.mkDefault "us";
}
