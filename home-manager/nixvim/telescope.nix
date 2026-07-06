{
  programs.nixvim.plugins.telescope = {
    enable = true;
    keymaps = {
      "<leader>ff" = "find_files";
      "<leader>fg" = "live_grep";
      # Git pickers (built-in — no extra extension needed)
      "<leader>gc" = "git_commits";
      "<leader>gs" = "git_status";
      "<leader>gb" = "git_branches";
    };
    extensions.fzf-native = { enable = true; };
  };
}
