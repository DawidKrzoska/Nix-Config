{
  config,
  pkgs,
  ...
}: let

  in{
	programs = {
		zsh.enable = true;
		starship.enable = true;
		};

}

