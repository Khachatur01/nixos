{
  description = "NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    # Local agentic development: Claude Code on a locally served model.
    # A path input, so /run/media/ssd2 has to be mounted to rebuild.
    local-ai-agent = {
      url = "path:/run/media/ssd2/self/projects/personal/local-ai-agent";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      # Build a NixOS system from hosts/<hostname>, with the shared modules applied.
      mkHost =
        {
          hostname,
          system ? "x86_64-linux",
          username ? "nixos",
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs hostname username; };
          modules = [
            ./modules/nixos
            ./hosts/${hostname}
          ];
        };
    in
    {
      nixosConfigurations = {
        rogstrix = mkHost { hostname = "rogstrix"; };
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
    };
}
