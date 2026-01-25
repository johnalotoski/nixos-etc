{
  pkgs,
  aiCommon,
  ...
}: let
  inherit (aiCommon) mkAgent;

  # Gemini-cli authenticator is currently not as nice as claude-code.
  #
  # If authentication by web is selected, the attempt to open a browser will timeout due to bubblewrap sandboxing.
  # If GEMINI_API_KEY is manually pasted, the attempt to save will fail again due to bubblewrap sandboxing.
  #
  # For now, on the first time authenticating, `read -s GEMINI_API_KEY; export GEMINI_API_KEY` before running `gemini`.
  # This will cache the credentials in the agent state dir and be used within the sandbox.
  # The gemini-cli debug panel will inform that system keychain is unavailable, which is due to bubblewrap sandboxing.
  #
  # Extending the sandboxing to allow browser sessions, dbus, security keychain access, etc, is not preferred.
  gemini-cli' = mkAgent {
    name = "gemini";
    agentApi = "generativelanguage.googleapis.com";
    agentPkg = pkgs.gemini-cli;
  };
in {
  environment.systemPackages = [
    gemini-cli'
  ];
}
