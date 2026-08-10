# Host side of the ai-microvm sandbox: kvm access plus an `ai-microvm` launcher.
# The guest itself is the nixosConfigurations.ai-microvm output (see flake.nix
# and microvm/ai-guest.nix). A writable-store microVM for running coding agents.
#
# Usage:
#   ai-microvm            # boot the VM, autologin console drops into ~/workspace
# claude and codex reuse host OAuth via mounted ~/.claude and ~/.codex. For
# gemini, export GEMINI_API_KEY before running and the launcher stages it into
# the secrets share. The writable-store overlay volume persists under
# ~/.local/share/ai-microvm.
{
  self,
  pkgs,
  ...
}: {
  # kvm for the hypervisor.
  users.users.jlotoski.extraGroups = ["kvm"];
  users.users.backup.extraGroups = ["kvm"];

  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "ai-microvm";
      runtimeInputs = [pkgs.coreutils];
      text = ''
        # Run from a persistent state dir so the overlay volume image lives
        # across runs rather than in the current directory.
        state="$HOME/.local/share/ai-microvm"
        mkdir -p "$state/secrets"
        chmod 700 "$state/secrets"

        # Dedicated writable workspace shared into the VM. Put code here.
        mkdir -p "$HOME/mvm"

        # Stage the gemini key from the host env into the secrets share, kept
        # out of the nix store. claude and codex use mounted OAuth instead.
        if [ -n "''${GEMINI_API_KEY:-}" ]; then
          printf '%s' "$GEMINI_API_KEY" > "$state/secrets/gemini-key"
          chmod 600 "$state/secrets/gemini-key"
        fi

        cd "$state"
        exec ${self.nixosConfigurations.ai-microvm.config.microvm.declaredRunner}/bin/microvm-run "$@"
      '';
    })
  ];
}
