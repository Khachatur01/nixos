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
  };
}
