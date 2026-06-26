{ pkgs, ... }: {
  # Notification daemon
  services.mako = {
    enable = true;
    settings = {
      anchor = "top-right";
      border-radius = 5;
      border-size = 2;
      default-timeout = 5000;
    };
  };
}
