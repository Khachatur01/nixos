{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    curl
    git
    htop
    pciutils
    usbutils
    vim
    wget
  ];

  programs.zsh.enable = true;
}
