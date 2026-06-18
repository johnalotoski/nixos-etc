{
  aiCommon,
  myPkgs,
  ...
}: let
  inherit (aiCommon) mkAgent;

  # Codex CLI (OpenAI) - similar sandbox setup to gemini.
  #
  # Authentication: set OPENAI_API_KEY in your environment before running.
  #   read -s OPENAI_API_KEY; export OPENAI_API_KEY
  # The key is passed into the sandbox if set in the calling environment and is
  # cached in the agent state directory for subsequent runs.
  #
  # Internal sandbox note: codex ships its own codex-linux-sandbox binary for
  # subprocess isolation.  This outer bubblewrap layer contains the codex
  # process itself; nested user-namespace creation works because
  # security.unprivilegedUsernsClone = true is set in ai-common.nix.
  # All codex helper binaries (codex-linux-sandbox, codex-exec, etc.) are
  # included automatically via agentPkg in the wrapped PATH.
  codex' = mkAgent {
    name = "codex";
    agentApi = "api.openai.com";
    agentEnvVars = ["OPENAI_API_KEY"];
    agentPkg = myPkgs.pkgs-llm.codex;
  };
in {
  environment.systemPackages = [
    codex'
  ];
}
