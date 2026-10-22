# NixOS configurations

```
flake.nix                  # inputs + mkHost helper, one entry per host
modules/nixos/             # shared modules imported by every host (all are workstations)
modules/nixos/desktop/     # desktop environments; each host imports one (plasma or gnome)
modules/nixos/programs/    # apps/services every host gets (steam, kdeconnect)
modules/home-manager/      # per-user dotfiles/config, applied to `username` via home-manager
hosts/<hostname>/          # host-specific config + hardware-configuration.nix
```

## Installing on rogstrix

Boot the NixOS minimal ISO (UEFI), connect to the network (`nmtui`), then:

Target is the Intel 512 GB SSD. Do NOT touch the Crucial 1 TB data SSD
(`CT1000P3SSD8`); it is mounted at `/run/media/ssd2` by the config.
`/dev/nvmeXn1` names can swap between boots, so use the stable by-id path.

```sh
# 0. Identify the disk: the INTEL one, 476.9G
lsblk -o NAME,SIZE,MODEL
ls -l /dev/disk/by-id/ | grep -v part
DISK=/dev/disk/by-id/nvme-INTEL_SSDPEKNU512GZ_BTKA11110RL2512A

# 1. Partition (DESTROYS everything on $DISK)
sudo parted "$DISK" -- mklabel gpt
sudo parted "$DISK" -- mkpart ESP fat32 1MiB 1GiB
sudo parted "$DISK" -- set 1 esp on
sudo parted "$DISK" -- mkpart root ext4 1GiB 100%
sudo udevadm settle
sudo mkfs.fat -F 32 -n NIXBOOT "$DISK-part1"
sudo mkfs.ext4 -L NIXROOT "$DISK-part2"

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

1. `mkdir hosts/<name>` with a `default.nix` (host-specific settings, one desktop import
   such as `../../modules/nixos/desktop/plasma.nix`, `system.stateVersion`) and its
   `hardware-configuration.nix`.
2. Add `<name> = mkHost { hostname = "<name>"; };` to `nixosConfigurations` in `flake.nix`.
