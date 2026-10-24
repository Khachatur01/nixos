# Shared configuration applied to every host.
{
  imports = [
    ./boot.nix
    ./desktop/common.nix
    ./home-manager.nix
    ./locale.nix
    ./networking.nix
    ./wireguard.nix
    ./nix.nix
    ./packages.nix
    ./programs
    ./users.nix
  ];
}
