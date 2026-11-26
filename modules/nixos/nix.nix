{ inputs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      # Build on disk, not in /tmp, which is a RAM-backed tmpfs. The daemon
      # removes each build's dir when it ends; nixpkgs' tmpfiles rule sweeps
      # up dirs left by a crash after 7 days untouched.
      build-dir = "/nix/var/nix/builds";
      trusted-users = [ "@wheel" ];
      # Prebuilt CUDA packages unfree, so not on cache.nixos.org.
      extra-substituters = [ "https://cache.nixos-cuda.org" ];
      extra-trusted-public-keys = [
        "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    # Make `nix shell nixpkgs#foo` and <nixpkgs> use the same nixpkgs as the system.
    registry.nixpkgs.flake = inputs.nixpkgs;
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  };
}
