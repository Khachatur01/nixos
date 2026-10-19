# ASUS ROG Strix G513QM: Ryzen 9 5900HX (Radeon Vega iGPU) + RTX 3060 Mobile.
{ config, inputs, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/desktop/plasma.nix
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  hardware.enableRedistributableFirmware = true; # MT7921 Wi-Fi, AMD microcode
  hardware.bluetooth.enable = true;

  # Second NVMe (Crucial P3 1TB) with personal data; kept across reinstalls.
  fileSystems."/run/media/ssd2" = {
    device = "/dev/disk/by-uuid/65417213-c476-45af-98bd-5a4d4bb6c43a";
    fsType = "ext4";
    options = [
      "nofail"
      "x-systemd.device-timeout=5"
    ];
  };

  # NVIDIA dGPU in PRIME offload mode; run apps on it with `nvidia-offload <cmd>`.
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      amdgpuBusId = "PCI:6:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # ASUS laptop tooling (fan profiles, keyboard backlight, charge limit).
  services.asusd.enable = true;
  services.power-profiles-daemon.enable = true;

  # Run Ollama on the NVIDIA dGPU.
  services.ollama.package = pkgs.ollama-cuda;

  # Set at install time, never change afterwards. See `man configuration.nix`.
  system.stateVersion = "26.05";
}
