{ pkgs, ... }:
{
  home.packages = with pkgs; [
    telegram-desktop
    zed-editor
    claude-code
  ];
}
