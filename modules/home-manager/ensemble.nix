{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [ inputs.ensemble.homeManagerModules.default ];

  # This computer's node: it starts once `ensemble node setup` has written
  # ~/.config/ensemble/node/node.yaml. Its teams and hub are managed with
  # `ensemble`.
  services.ensemble.node = {
    enable = true;
    # The agent CLIs its teams run.
    extraPackages = [
      pkgs.claude-code
      pkgs.opencode
    ];
  };

  # Agent sessions reach the node through `ensemble mcp`.
  programs.mcp.servers.ensemble = {
    command = lib.getExe config.services.ensemble.node.package;
    args = [ "mcp" ];
  };
}
