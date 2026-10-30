{ inputs, username, ... }:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs; };
    users.${username} = {
      imports = [
        inputs.plasma-manager.homeModules.plasma-manager
        ../home-manager
      ];
      home.username = username;
      home.homeDirectory = "/home/${username}";
    };
  };
}
