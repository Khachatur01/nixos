{ lib, pkgs, ... }:
let
  showSeconds = 20;
  shortcut = "Meta+Shift+I";

  # Toggle: show the widget (auto-hides after showSeconds), or hide it if shown.
  conkyPeek = pkgs.writeShellScriptBin "conky-peek" ''
    if systemctl --user is-active --quiet conky.service; then
      systemctl --user stop conky.service
    else
      systemctl --user start conky.service
    fi
  '';
in
{
  # CPU threads, GPUs (NVIDIA/AMD) and disks are discovered at runtime in conky/widgets.lua.

  # Not started at login: the widget is shown on demand (shortcut, launcher
  # entry or `conky-peek`) and stopped by systemd after `showSeconds`, so
  # nothing is polled while it is hidden.
  systemd.user.services.conky = {
    Install.WantedBy = lib.mkForce [ ];
    Service = {
      Restart = lib.mkForce "no";
      RuntimeMaxSec = showSeconds;
    };
  };

  home.packages = [ conkyPeek ];

  # Appears in the application launcher.
  xdg.desktopEntries.conky-peek = {
    name = "System Monitor (${shortcut})";
    comment = "Show the conky widget for ${toString showSeconds} seconds";
    exec = "conky-peek";
    icon = "utilities-system-monitor";
    terminal = false;
    categories = [ "System" ];
  };

  # Global shortcut (toggle).
  programs.plasma.hotkeys.commands.conky-peek = {
    name = "Toggle system monitor widget";
    key = shortcut;
    command = "${conkyPeek}/bin/conky-peek";
  };

  # Small floating panel with one button; hover tooltip shows the shortcut.
  programs.plasma.panels = [
    {
      location = "top";
      alignment = "right";
      lengthMode = "fit";
      height = 32;
      floating = true;
      offset = 24;
      widgets = [
        {
          name = "org.kde.plasma.quicklaunch";
          config.General = {
            launcherUrls = [ "applications:conky-peek.desktop" ];
            showLauncherNames = true;
          };
        }
      ];
    }
  ];
  services.conky = {
    enable = true;
    package = pkgs.conky;
    extraConfig = ''
      conky.config = {
        update_interval = 1,
        double_buffer = true,
        background = false,

        own_window = true,
        own_window_type = 'desktop',
        own_window_transparent = false,
        own_window_colour = '#aa11111b',
        own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',

        alignment = 'top_right',
        gap_x = 24,
        gap_y = 48,
        minimum_width = 310, maximum_width = 310,
        border_inner_margin = 16,
        border_width = 0,

        use_xft = true,
        font = 'monospace:size=9',
        draw_shades = false,
        draw_outline = false,
        draw_borders = false,
        draw_graph_borders = false,
        default_color = 'cdd6f4',
        color1 = '89b4fa',   -- values
        color2 = '6c7086',   -- labels
        color3 = 'cba6f7',   -- headings
        color4 = 'a6e3a1',   -- graphs

        cpu_avg_samples = 2,
        net_avg_samples = 2,
        no_buffers = true,
        text_buffer_size = 4096,
        lua_load = '${./conky/widgets.lua}',
      }

      conky.text = [[
      ''${color3}''${font monospace:bold:size=11}SYSTEM''${font}''${color}''${hr 2}
      ''${color2}Host''${goto 80}''${color}''${nodename}
      ''${color2}Kernel''${goto 80}''${color}''${kernel}
      ''${color2}Uptime''${goto 80}''${color}''${uptime}

      ''${color3}''${font monospace:bold:size=11}CPU''${font}  ''${color1}''${freq_g} GHz''${alignr}''${cpu cpu0}%''${color}''${hr 2}
      ''${color4}''${cpugraph cpu0 30,278 a6e3a1 89b4fa}
      ''${lua_parse cpu_rows}

      ''${lua_parse gpu_section}
      ''${color3}''${font monospace:bold:size=11}MEMORY''${font}''${color}''${hr 2}
      ''${color2}RAM''${goto 80}''${color1}''${mem} / ''${memmax}''${alignr}''${memperc}%
      ''${color4}''${membar 6}
      ''${color2}Swap''${goto 80}''${color1}''${swap} / ''${swapmax}''${alignr}''${swapperc}%
      ''${color4}''${swapbar 6}

      ''${color3}''${font monospace:bold:size=11}DISK''${font}''${color}''${hr 2}
      ''${lua_parse disk_section}
      ''${color2}Read''${goto 80}''${color1}''${diskio_read}''${goto 170}''${color2}Write''${goto 215}''${color1}''${diskio_write}
      ''${color4}''${diskiograph 24,278 a6e3a1 89b4fa}

      ''${color3}''${font monospace:bold:size=11}TOP''${font}''${color}''${hr 2}
      ''${color1}''${top name 1}''${alignr}''${top cpu 1}%
      ''${color}''${top name 2}''${alignr}''${top cpu 2}%
      ''${color}''${top name 3}''${alignr}''${top cpu 3}%
      ]]
    '';
  };
}
