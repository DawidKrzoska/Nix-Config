{ lib, pkgs, ... }: {
  home.packages = with pkgs; [ grim slurp satty ];

  home.activation.createPicturesDirectory =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "$HOME/Pictures"
    '';
}
