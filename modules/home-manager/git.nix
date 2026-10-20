{ ... }:
{
  programs.git = {
    enable = true;
    userName = "Khachatur Yeritsyan";
    userEmail = "yeritsyan.kh.01@gmail.com";

    extraConfig = {
        safe = {
          directory = [
            "/etc/nixos"
            "/run/media/ssd2/seld/projects/**"
          ];
        };
      };
  };
}
