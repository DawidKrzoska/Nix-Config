{
  programs.nixvim = {
    plugins.diffview = {
      enable = true;
      settings.enhanced_diff_hl = true;
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>gd";
        action = "<cmd>DiffviewOpen<CR>";
        options.desc = "Diff working tree changes";
      }
      {
        mode = "n";
        key = "<leader>gD";
        action = "<cmd>DiffviewOpen origin/main...HEAD<CR>";
        options.desc = "Diff committed branch vs main";
      }
    ];
  };
}
