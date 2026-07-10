{ config, lib, pkgs, inputs, ... }: {
  skills = {
    paths = [
      ".opencode/skills"
      "~/.config/opencode/skills"
    ];
    # Load Supabase-maintained agent skills alongside local and global skills.
    urls = [ "https://supabase.com/.well-known/agent-skills/" ];
  };
}
