# ai-microvm guest: a self-owned microvm.nix VM with a writable /nix store, so
# the agent can run nix eval and flake checks that a read-only shared store
# cannot. qemu + user-mode slirp gives egress with no host networking, and a
# console autologin avoids ssh and taps.
#
# shareHostStore true shares the host /nix/store as the overlay lower (launcher
# modes shared and full); false builds an isolated store image with no host store
# (mode isolated). The ai-microvm launcher picks the mode.
#
# Auth: the VM's /root home is a dedicated host dir, so claude/codex logins and
# config persist across reboots and never touch your host ~/.claude or ~/.codex;
# gemini uses GEMINI_API_KEY staged by the launcher into a secrets share.
{
  pkgs,
  lib,
  config,
  myPkgs,
  shareHostStore,
  ...
}: let
  # Host paths shared in. homeSource is the VM's whole /root home on a dedicated
  # host dir, so all agent config and logins (.claude, .codex, .claude.json, ...)
  # persist across reboots and stay off your host ~/.claude / ~/.codex.
  # workspaceSource is a dedicated writable dir kept off ~/ai/share so the VM
  # cannot reach ssh masters or other secrets there; put the code you want the
  # agent to work on into ~/mvm.
  homeSource = "/home/jlotoski/.local/share/ai-microvm/home";
  workspaceSource = "/home/jlotoski/mvm";

  # The launcher writes the gemini key here before boot; kept out of the store.
  secretsSource = "/home/jlotoski/.local/share/ai-microvm/secrets";

  # "full" mode: the launcher dumps the host nix db here for the guest to load at
  # boot; empty in other modes so the load-db service is skipped.
  hostdbSource = "/home/jlotoski/.local/share/ai-microvm/hostdb";

  # Runtime egress toggle, run inside the guest. Boot default is on (no rule).
  # "off" installs an nftables output drop keeping only loopback; "on" removes
  # it. SLIRP has no allowlist, so egress control lives here in the guest.
  netguard = pkgs.writeShellApplication {
    name = "netguard";
    runtimeInputs = [pkgs.nftables];
    text = ''
      case "''${1:-status}" in
        off)
          if nft list table inet netguard >/dev/null 2>&1; then
            nft delete table inet netguard
          fi
          nft add table inet netguard
          nft 'add chain inet netguard output { type filter hook output priority 0; policy drop; }'
          nft add rule inet netguard output oifname lo accept
          echo "egress: off"
          ;;
        on)
          if nft list table inet netguard >/dev/null 2>&1; then
            nft delete table inet netguard
          fi
          echo "egress: on"
          ;;
        status)
          if nft list table inet netguard >/dev/null 2>&1; then
            echo "egress: off"
          else
            echo "egress: on"
          fi
          ;;
        *)
          echo "usage: netguard {on|off|status}" >&2
          exit 1
          ;;
      esac
    '';
  };
in {
  microvm = {
    hypervisor = "qemu";
    vcpu = 6;
    mem = 12288;

    # Writable /nix/store = overlay of a read-only lower + a writable upper on a
    # volume, so nix can write drvs and copied flake sources. This is the whole
    # point of the VM. When shareHostStore, the lower is the host store shared
    # over 9p; otherwise microvm builds a store image of just the guest closure.
    #
    # 9p not virtiofs: virtiofs needs the virtiofsd helper daemon, which did not
    # come up here, its userns sandbox cannot set up id maps unprivileged. 9p is
    # in-process in qemu, no daemon. Slower store I/O but fine for eval and
    # review; revisit virtiofs if it drags.
    #
    # 9p over an unprivileged qemu cannot map host ownership to the guest user
    # (passthrough/none need qemu as root), so the mounts show as root:root and
    # the guest runs as root to reach them.
    shares =
      (
        if shareHostStore
        then [
          {
            proto = "9p";
            tag = "ro-store";
            source = "/nix/store";
            mountPoint = "/nix/.ro-store";
            readOnly = true;
          }
          {
            proto = "9p";
            tag = "hostdb";
            source = hostdbSource;
            mountPoint = "/run/host-nix-db";
            readOnly = true;
          }
        ]
        else []
      )
      ++ [
        {
          proto = "9p";
          tag = "home";
          source = homeSource;
          mountPoint = "/root";
        }
        {
          proto = "9p";
          tag = "workspace";
          source = workspaceSource;
          mountPoint = "/workspace";
        }
        {
          proto = "9p";
          tag = "secrets";
          source = secretsSource;
          mountPoint = "/run/agent-secrets";
          readOnly = true;
        }
      ];

    writableStoreOverlay = "/nix/.rw-store";
    # Upper holds only paths not already in the lower. Per-mode image so shared
    # and isolated do not mix layers. Sparse on the big /home; delete it to reset
    # (or use the launcher --reset).
    volumes = [
      {
        image =
          if shareHostStore
          then "nix-rw-store.img"
          else "nix-rw-store-isolated.img";
        mountPoint = "/nix/.rw-store";
        size = 131072;
      }
    ];

    # User-mode slirp: NAT egress with no host bridge, tap, or firewall. No ssh,
    # so no port forwards needed; access is the autologin console.
    interfaces = [
      {
        type = "user";
        id = "usernet";
        mac = "02:00:00:00:00:02";
      }
    ];
  };

  # 9p over the unprivileged qemu maps the shares to root:root, so the console
  # runs as root to reach them. claude allows --dangerously-skip-permissions as
  # root when IS_SANDBOX is set, honest here since this is a disposable VM.
  # poweroff also works directly as root.
  services.getty.autologinUser = "root";
  environment.variables.IS_SANDBOX = "1";

  environment.loginShellInit = ''
    [ -r /run/agent-secrets/gemini-key ] && export GEMINI_API_KEY="$(cat /run/agent-secrets/gemini-key)"
    cd /workspace 2>/dev/null || true
    echo "egress toggle: netguard {on|off|status} (default on)"
  '';

  networking.hostName = "ai-microvm";
  networking.useNetworkd = true;
  systemd.network.enable = true;
  systemd.network.networks."10-usernet" = {
    matchConfig.Type = "ether";
    networkConfig.DHCP = "yes";
  };

  # full mode: register the whole host store db the launcher dumped in. Skipped
  # when the file is empty (shared mode) via ConditionFileNotEmpty. Only present
  # when the host store is shared.
  systemd.services.import-host-store-db = lib.mkIf shareHostStore {
    description = "Register the host store db when provided (full store mode)";
    wantedBy = ["multi-user.target"];
    before = ["multi-user.target"];
    unitConfig = {
      ConditionFileNotEmpty = "/run/host-nix-db/registration";
      RequiresMountsFor = "/run/host-nix-db /nix/store";
    };
    path = [config.nix.package];
    serviceConfig.Type = "oneshot";
    script = "nix-store --load-db < /run/host-nix-db/registration";
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    trusted-users = ["root"];

    # Bake in the IOG cache so cardano/haskell.nix evals substitute GHC and the
    # plan derivations instead of building them, with no --accept-flake-config
    # needed per invocation.
    substituters = [
      "https://cache.nixos.org"
      "https://cache.iog.io"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    ];
  };

  # The unwrapped agents from llm-agents, same pins as the host bwrap agents.
  environment.systemPackages =
    [
      myPkgs.pkgs-llm.claude-code
      myPkgs.pkgs-llm.codex
      myPkgs.pkgs-llm.gemini-cli
      netguard
    ]
    ++ (with pkgs; [git ripgrep fd jq]);

  system.stateVersion = "26.05";
}
