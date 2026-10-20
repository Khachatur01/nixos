{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Khachatur Yeritsyan";
        email = "yeritsyan.kh.01@gmail.com";
      };
      safe.directory = [
        "/etc/nixos"
        "/run/media/ssd2/seld/projects/**"
      ];
    };
  };
}
