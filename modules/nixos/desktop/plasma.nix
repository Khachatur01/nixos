{
  imports = [ ./common.nix ];

  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  home-manager.sharedModules = [ ../../home-manager/plasma.nix ];
}
