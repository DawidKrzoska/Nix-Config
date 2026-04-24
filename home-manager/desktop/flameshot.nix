{ lib, ... }: {
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
