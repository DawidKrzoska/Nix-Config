{

  programs.nixvim.globals.mapleader = " ";
  programs.nixvim.opts = {
    updatetime = 50; # Faster completion
    number = true;
    autoindent = true;
    expandtab = true;
    tabstop = 4;
    softtabstop = 4;
    shiftwidth = 4;
    smartindent = true;
    breakindent = true;
  };
}
