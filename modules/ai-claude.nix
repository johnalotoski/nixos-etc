{
  pkgs,
  aiCommon,
  myPkgs,
  ...
}: let
  inherit (aiCommon) aiHome aiState aiToolsCommon mkAgent;

  # There are still claude code issues with respecting XDG vars properly.
  # https://github.com/anthropics/claude-code/issues/1455
  claude-monitor' = pkgs.writeShellApplication {
    name = "claude-monitor";
    runtimeInputs = with myPkgs.pkgs-ai; [claude-monitor];
    text = ''
      AI_ROOT="$HOME/${aiHome}"
      SANDBOX_HOME="$AI_ROOT/${aiState}/.claude-home"
      export HOME="$SANDBOX_HOME"

      exec claude-monitor "$@"
    '';
  };

  claude-code' = mkAgent {
    name = "claude";
    # bubblewrap: needed if claude spawns sub-agents in nested sandboxes.
    # socat: used by MCP servers and tool proxies that claude-code manages.
    # sox: required by the /voice command for audio recording (rec/play).
    # MCP servers (register once with `claude mcp add` inside a session):
    #   First-time setup commands (run manually once per user):
    #     claude mcp add git mcp-server-git
    #     claude mcp add fetch mcp-server-fetch
    #     claude mcp add github github-mcp-server -- stdio
    #   github-mcp-server: reads GITHUB_PERSONAL_ACCESS_TOKEN; GITHUB_TOKEN is
    #   also accepted and mapped to that name by the sandbox wrapper.
    aiTools = aiToolsCommon {
      aiToolsExtra = with pkgs; [
        bubblewrap
        myPkgs.pkgs-ai.github-mcp-server
        myPkgs.pkgs-ai.mcp-server-fetch
        myPkgs.pkgs-ai.mcp-server-git
        socat
        sox
      ];
    };
    agentApi = "api.anthropic.com";
    agentEnvVars = ["ANTHROPIC_API_KEY"];
    agentPkg = myPkgs.pkgs-ai.claude-code;
  };
in {
  environment.systemPackages = [
    claude-code'
    claude-monitor'
  ];
}
