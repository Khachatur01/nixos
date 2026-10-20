{ ... }:
{
  programs.zed-editor = {
    enable = true;

    userSettings = {
      autosave = "on_focus_change";
      agent_servers = {
        claude-acp = {
          type = "registry";
        };
      };
      base_keymap = "JetBrains";
      project_panel = {
        dock = "left";
      };
      git_panel = {
        dock = "left";
      };
      agent = {
        dock = "right";
      };
      terminal = {
        dock = "bottom";
      };
      bottom_dock_layout = "full";
      ui_font_size = 16;
      buffer_font_size = 15;
      theme = {
        mode = "system";
        light = "One Light";
        dark = "One Dark";
      };
    };
  };
}
