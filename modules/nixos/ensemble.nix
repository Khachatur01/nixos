{ inputs, username, ... }:
{
  imports = [ inputs.ensemble.nixosModules.default ];

  # A hub of my own, run as me from ~/.config/ensemble/hub/, configured with
  # `ensemble hub …`. It starts once `ensemble hub init` has written hub.yaml.
  services.ensemble.hub = {
    enable = true;
    user = username;
  };
}
