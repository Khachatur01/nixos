{ pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    kdePackages.kcalc
    kdePackages.krdc
    telegram-desktop
    unsloth-desktop
    vlc
  ];
}
