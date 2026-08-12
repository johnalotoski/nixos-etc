# Host side of the ai-microvm sandbox: kvm access plus an `ai-microvm` launcher.
# The guest is the nixosConfigurations.ai-microvm{,-isolated} output (flake.nix
# and microvm/ai-guest.nix). A writable-store microVM for running coding agents.
#
# Usage:
#   ai-microvm [shared|full|isolated] [--reset]
#     shared    (default) host store shared read-only, only the system closure
#               registered; the guest fetches its own deps from caches
#     full      shared, plus the whole host store registered at boot so host
#               built deps are reused in place; slower boot from the load-db
#     isolated  no host store shared, a built store image of just the guest
#     --reset   wipe this mode's overlay upper before booting
#
# The VM's whole home (/root) is a dedicated host dir (state/home), so all agent
# config and logins (.claude, .codex, .claude.json) persist across reboots and
# stay off your host ~/.claude / ~/.codex; log in once inside the VM and it
# sticks. Workspace is /workspace (~/mvm). For gemini, export GEMINI_API_KEY
# before running; the launcher stages it into the secrets share. All state lives
# under ~/.local/share/ai-microvm.
{
  self,
  pkgs,
  ...
}: let
  sharedRunner = self.nixosConfigurations.ai-microvm.config.microvm.declaredRunner;
  isolatedRunner = self.nixosConfigurations.ai-microvm-isolated.config.microvm.declaredRunner;
in {
  # kvm for the hypervisor.
  users.users.jlotoski.extraGroups = ["kvm"];
  users.users.backup.extraGroups = ["kvm"];

  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "ai-microvm";
      runtimeInputs = [pkgs.coreutils pkgs.nix];
      text = ''
        mode=shared
        reset=0
        for a in "$@"; do
          case "$a" in
            shared | full | isolated) mode="$a" ;;
            --reset) reset=1 ;;
            -h | --help)
              echo "usage: ai-microvm [shared|full|isolated] [--reset]"
              echo "  shared    (default) host store shared read-only, system closure registered"
              echo "  full      shared, plus the whole host store registered at boot (slower boot)"
              echo "  isolated  no host store shared, built store image only"
              echo "  --reset   wipe this mode's overlay upper before booting"
              exit 0
              ;;
            *)
              echo "ai-microvm: unknown arg '$a'" >&2
              exit 1
              ;;
          esac
        done

        state="$HOME/.local/share/ai-microvm"
        mkdir -p "$state/secrets" "$state/hostdb" "$state/home" "$HOME/mvm"
        chmod 700 "$state/secrets" "$state/home"

        # gemini key (all modes); claude and codex use mounted OAuth
        if [ -n "''${GEMINI_API_KEY:-}" ]; then
          printf '%s' "$GEMINI_API_KEY" > "$state/secrets/gemini-key"
          chmod 600 "$state/secrets/gemini-key"
        fi

        # host store db: full registers everything, other modes register nothing
        reg="$state/hostdb/registration"
        if [ "$mode" = full ]; then
          if ! nix-store --dump-db > "$reg" 2>/dev/null; then
            echo "ai-microvm: reading the host nix db needs root; using sudo" >&2
            sudo ${pkgs.nix}/bin/nix-store --dump-db | tee "$reg" > /dev/null
          fi
        else
          : > "$reg"
        fi

        # pick the runner and this mode's overlay upper
        if [ "$mode" = isolated ]; then
          runner=${isolatedRunner}
          img=nix-rw-store-isolated.img
        else
          runner=${sharedRunner}
          img=nix-rw-store.img
        fi

        if [ "$reset" = 1 ]; then
          rm -f "$state/$img"
          echo "ai-microvm: reset removed $img"
        fi

        cd "$state"
        echo "ai-microvm: booting [store=$mode]"
        exec "$runner/bin/microvm-run"
      '';
    })
  ];
}
