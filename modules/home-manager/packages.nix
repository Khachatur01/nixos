{ pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    kdePackages.kcalc
    kdePackages.krdc
    telegram-desktop
    claude-code
    opencode
    harmonoid
    unsloth-desktop
    inputs.ensemble.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
