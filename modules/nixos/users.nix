{ pkgs, username, ... }:
{
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
    ];
    shell = pkgs.zsh;
    # Change it after the first login with `passwd`.
    initialPassword = "changeme";
  };

  security.sudo.wheelNeedsPassword = true;
}
