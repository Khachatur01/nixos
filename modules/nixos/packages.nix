{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    curl
    htop
    pciutils
    usbutils
    vim
    wget
  ];

  programs.zsh.enable = true;
  programs.firefox.enable = true;
}
