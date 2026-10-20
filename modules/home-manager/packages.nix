{ pkgs, ... }:
{
  home.packages = with pkgs; [
    telegram-desktop
    claude-code
  ];
}
