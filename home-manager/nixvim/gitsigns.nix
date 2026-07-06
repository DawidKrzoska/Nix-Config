{
  programs.nixvim = {
    plugins.gitsigns = {
      enable = true;

      settings = {
        # Show who wrote the current line (toggle with <leader>gb)
        current_line_blame = true;
        current_line_blame_opts.delay = 500;

        # Signs in the gutter for added/changed/removed lines
        signs = {
          add = { text = "│"; };
          change = { text = "│"; };
          delete = { text = "_"; };
          topdelete = { text = "‾"; };
          changedelete = { text = "~"; };
        };
      };
    };

    keymaps = [
      # Hunk navigation
      {
        mode = "n";
        key = "]c";
        action = "<cmd>lua require('gitsigns').next_hunk()<CR>";
        options.desc = "Next git hunk";
      }
      {
        mode = "n";
        key = "[c";
        action = "<cmd>lua require('gitsigns').prev_hunk()<CR>";
        options.desc = "Previous git hunk";
      }
      # Toggle line blame
      {
        mode = "n";
        key = "<leader>gl";
        action = "<cmd>lua require('gitsigns').blame_line()<CR>";
        options.desc = "Git blame line";
      }
      # Preview / stage / reset hunks
      {
        mode = "n";
        key = "<leader>gp";
        action = "<cmd>lua require('gitsigns').preview_hunk()<CR>";
        options.desc = "Preview git hunk";
      }
      {
        mode = "n";
        key = "<leader>gs";
        action = "<cmd>lua require('gitsigns').stage_hunk()<CR>";
        options.desc = "Stage git hunk";
      }
      {
        mode = "n";
        key = "<leader>gS";
        action = "<cmd>lua require('gitsigns').undo_stage_hunk()<CR>";
        options.desc = "Unstage git hunk";
      }
      {
        mode = "n";
        key = "<leader>gr";
        action = "<cmd>lua require('gitsigns').reset_hunk()<CR>";
        options.desc = "Reset git hunk";
      }
    ];
  };
}
