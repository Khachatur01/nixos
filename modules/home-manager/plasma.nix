{ config, lib, ... }:
{
  options.custom.plasma.restoreSession = lib.mkEnableOption "restoring the previous session after login";

  config.programs.plasma = {
    enable = true;

    # KRDP authenticates the logged-in user through PAM. Point it at the
    # certificate managed by the NixOS KRDP service instead of the one-day
    # certificate the KCM generates.
    configFile."krdpserverrc"."General" = {
      SystemUserEnabled = true;
      Users = "";
      Certificate = "${config.home.homeDirectory}/.local/share/krdpserver/krdp.crt";
      CertificateKey = "${config.home.homeDirectory}/.local/share/krdpserver/krdp.key";
    };

    # Taskbar. Declaring it makes plasma-manager replace any existing panels.
    panels = [
      {
        location = "bottom";
        alignment = "center";
        lengthMode = "fill";
        hiding = "none";
        opacity = "adaptive";
        floating = false;
        height = 32;
        widgets = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.pager"
          {
            iconTasks.launchers = [
              "applications:systemsettings.desktop"
              "applications:org.kde.konsole.desktop"
              "applications:org.kde.dolphin.desktop"
              "applications:org.kde.kcalc.desktop"
              "applications:org.kde.kate.desktop"
              "applications:dev.zed.Zed.desktop"
              "applications:firefox.desktop"
              "applications:org.telegram.desktop.desktop"
            ];
          }
          "org.kde.plasma.marginsseparator"
          {
            systemTray.items.shown = [ "org.kde.plasma.battery" ];
          }
          {
            digitalClock = {
              time = {
                format = "24h";
                showSeconds = "always";
              };
              date = {
                enable = true;
                format.custom = "dd/MM/yyyy";
              };
            };
          }
          "org.kde.plasma.showdesktop"
        ];
      }
    ];

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

    # Reopen the previous session's apps at login only when
    # `custom.plasma.restoreSession` is enabled.
    configFile."ksmserverrc"."General"."loginMode" =
      if config.custom.plasma.restoreSession then "restorePreviousLogout" else "emptySession";

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
