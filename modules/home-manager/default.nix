{ ... }:
{
  imports = [
    ./claude-code.nix
    ./conky.nix
    ./freecad.nix
    ./mcp.nix
    ./git.nix
    ./kicad.nix
    ./opencode.nix
    ./packages.nix
    ./zed.nix
    ./zsh.nix
  ];

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}
