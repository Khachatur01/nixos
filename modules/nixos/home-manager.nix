{ inputs, username, ... }:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.${username} = {
      imports = [ ../home-manager ];
      home.username = username;
      home.homeDirectory = "/home/${username}";
    };
  };
}
