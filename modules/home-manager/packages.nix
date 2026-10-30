{ pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    kdePackages.kcalc
    kdePackages.krdc
    telegram-desktop
    claude-code
    opencode
    harmonoid
    inputs.ensemble.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
