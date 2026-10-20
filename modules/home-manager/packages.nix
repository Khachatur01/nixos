{ pkgs, ... }:
{
  home.packages = with pkgs; [
    kdePackages.kcalc
    telegram-desktop
    claude-code
  ];
}
