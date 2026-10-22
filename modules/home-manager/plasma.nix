{
  programs.plasma = {
    enable = true;
    input.keyboard.layouts = [
      { layout = "us"; }
      {
        layout = "am";
        variant = "phonetic-alt";
      }
      { layout = "ru"; }
    ];
    input.keyboard.options = [ "grp:win_space_toggle" ];
    input.keyboard.switchingPolicy = "window";
    input.keyboard.numlockOnStartup = "on";

    configFile."plasmanotifyrc"."Notifications"."PopupPosition" = "TopRight";

    # Turn the wallet subsystem off, so nothing offers to store secrets in it
    # and the first-use wizard never appears.
    configFile."kwalletrc"."Wallet" = {
      "Enabled" = false;
      "First Use" = false;
    };

    # Locking the screen must not suspend the system (so background work
    # keeps running); only closing the lid should suspend, and not even
    # then if an external monitor is connected (docked).
    powerdevil = {
      AC = {
        autoSuspend.action = "nothing";
        whenLaptopLidClosed = "sleep";
        inhibitLidActionWhenExternalMonitorConnected = true;
      };
      battery = {
        autoSuspend.action = "nothing";
        whenLaptopLidClosed = "sleep";
        inhibitLidActionWhenExternalMonitorConnected = true;
      };
    };
  };
}
