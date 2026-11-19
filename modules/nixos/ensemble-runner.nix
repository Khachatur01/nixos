{ pkgs, username, ... }:
{
  # This computer's runner, a systemd user service of mine, connected to my
  # hub (the module is imported in ensemble-hub.nix). Its settings are declared
  # here and merged into ~/.config/ensemble/runner/runner.yaml when it starts;
  # its hub token is made with `ensemble-runner login`, and kept in hubs.json.
  services.ensemble.runner = {
    enable = true;
    user = username;
    workspace = "~/ensemble";
    settings = {
      version = 1;
      name = "rogstrix";
      works_for = "owner";
      hub = "ws://127.0.0.1:7700";
      llm.direct = {
        backends = { };
        shares = [ ];
        max_shared_calls = 1;
      };
    };
    # The agent CLIs its teams run.
    extraPackages = [
      pkgs.claude-code
      pkgs.opencode
    ];
  };
}
