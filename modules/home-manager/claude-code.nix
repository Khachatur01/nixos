{ pkgs, ... }:
{
  # claude-work alias (zsh.nix) uses the same wrapped claude.
  programs.claude-code = {
    enable = true;
    package = pkgs.claude-code;
  };
}
