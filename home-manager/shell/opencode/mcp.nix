{ config, lib, pkgs, inputs, ... }: {
  mcp = {
    vercel = {
      type = "remote";
      url = "https://mcp.vercel.com";
      enabled = true;
    };
    supabase = {
      type = "remote";
      url = "https://mcp.supabase.com/mcp";
      enabled = true;
    };
    github = {
      type = "local";
      command = [
        "sh"
        "-c"
        "GITHUB_PERSONAL_ACCESS_TOKEN=$(gh auth token) exec npx -y @modelcontextprotocol/server-github"
      ];
      enabled = true;
    };
    playwright = {
      type = "local";
      command = [
        "${pkgs.playwright-mcp}/bin/playwright-mcp"
        "--headless"
        "--isolated"
      ];
      enabled = true;
    };
  };
}
