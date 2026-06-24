{ lib, pkgs, ... }: {
  home.packages = with pkgs; [ grim slurp ];

  xdg.desktopEntries."org.flameshot.Flameshot" = {
    name = "Flameshot";
    exec = "flameshot gui";
    icon = "org.flameshot.Flameshot";
    terminal = false;
    categories = [ "Graphics" ];
    actions = {
      "fullscreen" = {
        name = "Fullscreen screenshot";
        exec = "flameshot full -p /home/wolfar/Pictures";
      };
    };
  };

  services.flameshot = {
    enable = true;
    settings = {
      General = {
        disabledTrayIcon = false;
        showStartupLaunchMessage = false;
        savePath = "/home/wolfar/Pictures";
        savePathFixed = false;
        useGrimAdapter = true;
      };
    };
  };

  home.activation.createPicturesDirectory =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "$HOME/Pictures"
    '';
}
