{ ... }:
{
  imports = [
    ./git.nix
    ./packages.nix
    ./zed.nix
    ./zsh.nix
  ];

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}
