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
    runtimeInputs = with myPkgs.pkgs-latest; [claude-monitor];
    text = ''
      AI_ROOT="$HOME/${aiHome}"
      SANDBOX_HOME="$AI_ROOT/${aiState}/.claude-home"
      export HOME="$SANDBOX_HOME"

      exec claude-monitor "$@"
    '';
  };

  claude-code' = mkAgent {
    name = "claude";
    aiTools = aiToolsCommon {aiToolsExtra = with pkgs; [bubblewrap socat];};
    agentApi = "api.anthropic.com";
    agentPkg = myPkgs.pkgs-latest.claude-code;
  };
in {
  environment.systemPackages = [
    claude-code'
    claude-monitor'
  ];
}
