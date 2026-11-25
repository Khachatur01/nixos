{ inputs, pkgs, username, ... }:
{
  imports = [ inputs.ensemble.nixosModules.default ];

  services.ensemble = {
    ui.enable = true;

    # A hub of my own, run as me from ~/.local/state/ensemble/hub/, listening on
    # 127.0.0.1:7700. Nix only runs it: its settings and the keys of its backends
    # are kept in hub/core/database.db (keys sealed by master.key beside it; back
    # up the folder), and changed with `ensemble-hub setup`, `ensemble-hub
    # backend …`, `ensemble-hub settings …` and the rest.
    hub = {
      enable = true;
      user = username;
    };

    # This computer's runner, a systemd user service of mine, connected to my
    # hub (the module is imported in ensemble-hub.nix). Its settings are declared
    # here and merged into ~/.config/ensemble/runner/runner.yaml when it starts;
    # its hub token is made with `ensemble-runner login`, and kept in hubs.json.
    runner = {
      enable = true;
      user = username;
      # The agent CLIs its teams run.
      extraPackages = [
        pkgs.claude-code
        pkgs.opencode
      ];
    };
  };
}
