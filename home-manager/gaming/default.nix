{
  programs.mangohud.enable = true;

  # Reopen the main window when Steam is already running in the tray.
  xdg.desktopEntries.steam = {
    name = "Steam";
    comment = "Manage and play games on Steam";
    exec = "/run/current-system/sw/bin/steam steam://open/main";
    icon = "steam";
    terminal = false;
    categories = [
      "Game"
      "Network"
    ];
    mimeType = [
      "x-scheme-handler/steam"
      "x-scheme-handler/steamlink"
    ];
    settings = {
      PrefersNonDefaultGPU = "true";
      X-KDE-RunOnDiscreteGpu = "true";
    };
  };
}
