# Shared configuration applied to every host.
{
  imports = [
    ./boot.nix
    ./desktop/common.nix
    ./locale.nix
    ./networking.nix
    ./nix.nix
    ./packages.nix
    ./programs
    ./users.nix
  ];
}
