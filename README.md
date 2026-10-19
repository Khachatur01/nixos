# NixOS configurations

```
flake.nix                  # inputs + mkHost helper, one entry per host
modules/nixos/             # shared modules imported by every host
hosts/<hostname>/          # host-specific config + hardware-configuration.nix
```

## Installing on rogstrix

Boot the NixOS minimal ISO (UEFI), connect to the network (`nmtui`), then:

```sh
# 1. Partition (DESTROYS the disk — check the device with lsblk first)
sudo parted /dev/nvme0n1 -- mklabel gpt
sudo parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 1GiB
sudo parted /dev/nvme0n1 -- set 1 esp on
sudo parted /dev/nvme0n1 -- mkpart root ext4 1GiB 100%
sudo mkfs.fat -F 32 -n NIXBOOT /dev/nvme0n1p1
sudo mkfs.ext4 -L NIXROOT /dev/nvme0n1p2

# 2. Mount
sudo mount /dev/disk/by-label/NIXROOT /mnt
sudo mount --mkdir -o umask=077 /dev/disk/by-label/NIXBOOT /mnt/boot

# 3. Get this repo and generate the real hardware config
nix-shell -p git
git clone <this-repo> /mnt/etc/nixos && cd /mnt/etc/nixos
sudo nixos-generate-config --root /mnt --show-hardware-config > hosts/rogstrix/hardware-configuration.nix
git add -A   # flakes only see tracked files

# 4. Install and reboot
sudo nixos-install --flake .#rogstrix
reboot
```

Log in with the initial password `changeme` and change it with `passwd`.

## Day to day

```sh
sudo nixos-rebuild switch --flake .#rogstrix
nix flake update            # bump inputs, then rebuild
```

## Adding a host

1. `mkdir hosts/<name>` with a `default.nix` (host-specific settings + `system.stateVersion`)
   and its `hardware-configuration.nix`.
2. Add `<name> = mkHost { hostname = "<name>"; };` to `nixosConfigurations` in `flake.nix`.
