# ASUS ROG Strix G513QM: Ryzen 9 5900HX (Radeon Vega iGPU) + RTX 3060 Mobile.
{ config, inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  hardware.enableRedistributableFirmware = true; # MT7921 Wi-Fi, AMD microcode

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

  # Set at install time, never change afterwards. See `man configuration.nix`.
  system.stateVersion = "26.05";
}
