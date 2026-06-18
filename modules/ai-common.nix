{
  pkgs,
  config,
  ...
}: {
  _module.args.aiCommon = rec {
    # "$HOME/${aiHome}"
    # ├── ${aiShare}                    <--- Content available to all agents as RW mount
    # │   └── ${aiShareWorkspace}       <--- Agent workspace dir mounted from ${aiHomeWorkspace} below, not readable by other agents
    # └── ${aiState}
    #     ├── ${agentHomeName}          <--- Agent home state as RW mount; cannot RW any other agent home state
    #     │   ├── ${aiHomeWorkspace}    <--- Agent workspace dir is mounted to ${aiShareWorkspace} above, not readable by other agents
    #     │   └── ...
    #     └── ...
    aiHome = "ai";
    aiShare = "share";
    aiState = "state";
    aiWorkspace = "workspace";

    # Wrapped nix package that blocks GC operations inside the sandbox.
    # GC requests go to the host daemon which operates on the entire host
    # store — safe from a root-visibility standpoint (daemon sees all roots),
    # but an accidental `nix-collect-garbage -d` would delete the host user's
    # profile generations and could GC store paths the host still wants.
    nixSandboxed = let
      nix = config.nix.package;

      wrapperNix = pkgs.writeShellScriptBin "nix" ''
        case "''${1:-}" in
          store)
            case "''${2:-}" in
              gc|delete)
                echo "ERROR: 'nix store ''${2}' is blocked inside the AI sandbox." >&2
                exit 1
                ;;
            esac
            ;;
          collect-garbage)
            echo "ERROR: 'nix collect-garbage' is blocked inside the AI sandbox." >&2
            exit 1
            ;;
        esac
        exec ${nix}/bin/nix "$@"
      '';

      wrapperCollectGarbage = pkgs.writeShellScriptBin "nix-collect-garbage" ''
        echo "ERROR: nix-collect-garbage is blocked inside the AI sandbox." >&2
        exit 1
      '';

      wrapperNixStore = pkgs.writeShellScriptBin "nix-store" ''
        for arg in "$@"; do
          case "$arg" in
            --gc|--delete)
              echo "ERROR: 'nix-store $arg' is blocked inside the AI sandbox." >&2
              exit 1
              ;;
          esac
        done
        exec ${nix}/bin/nix-store "$@"
      '';
    in
      pkgs.symlinkJoin {
        name = "nix-sandboxed";
        paths = [
          wrapperNix
          wrapperCollectGarbage
          wrapperNixStore
          nix
        ];
      };

    aiToolsCommon = {aiToolsExtra ? [], ...}:
      pkgs.buildEnv {
        name = "ai-tools";
        paths =
          (with pkgs; [
            bashInteractive
            coreutils
            curl
            findutils
            gawk
            git
            gnugrep
            gnused
            jq
            openssh
            ripgrep
            tree
            which
          ])
          ++ [nixSandboxed]
          ++ aiToolsExtra;
      };

    mkAgent = {
      name,
      aiHomeWorkspace ? ".${name}-${aiWorkspace}",
      aiShareWorkspace ? ".${name}",
      aiTools ? aiToolsCommon {},
      agentApi,
      agentEnvVars ? [],
      agentHomeName ? ".${name}-home",
      agentPkg,
      wrappedName ? "${name}-wrapped",
      ...
    }: let
      agentWrapped = pkgs.writeShellApplication {
        name = wrappedName;
        runtimeInputs = with pkgs; [
          agentPkg
          coreutils
          curl
          getent
        ];
        text = ''
          if [ -n "''${DEBUG:-}" ]; then
            set -x

            echo "Bubblewrap runtime user is:"
            id

            echo "Agent API resolution:"
            getent hosts ${agentApi} || true

            echo "IPv6 and IPv6 Agent API connectivity:"
            curl -6 --connect-timeout 10 https://${agentApi} || echo "IPv6 failed"
            curl -4 --connect-timeout 10 https://${agentApi} || echo "IPv4 failed"
          fi

          ${pkgs.lib.getExe agentPkg} "$@"
        '';
      };
    in
      pkgs.writeShellApplication {
        inherit name;
        runtimeInputs = with pkgs; [
          bubblewrap
        ];
        text = ''
          set -euo pipefail

          AI_ROOT="$HOME/${aiHome}"
          SHARE="$AI_ROOT/${aiShare}"
          STATE="$AI_ROOT/${aiState}"
          AGENT_HOME="$STATE/${agentHomeName}"
          AGENT_HOME_WS="$AGENT_HOME/${aiHomeWorkspace}"

          mkdir -p "$SHARE" "$AGENT_HOME"/{.config,.cache,.local/share,.local/state,.config/nix} "$AGENT_HOME_WS"

          CACERT="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
          CACERT_DIR="${pkgs.cacert}/etc/ssl/certs"

          TOOLS="${aiTools}/bin"

          args=()

          # --- Clear inherited environment (all vars must be explicit below) ---
          args+=( --clearenv )

          # --- Namespace isolation ---
          args+=( --unshare-user --unshare-pid --unshare-uts --unshare-cgroup )
          args+=( --die-with-parent )

          # --- Basic FS ---
          args+=( --proc /proc )
          args+=( --dev /dev )
          args+=( --tmpfs /tmp )

          # --- Nix store (binaries + libs) ---
          args+=( --ro-bind /nix /nix )

          # --- Minimal /etc (start empty) ---
          args+=( --tmpfs /etc )
          args+=( --bind-try /etc/hosts /etc/hosts )
          args+=( --bind-try /etc/resolv.conf /etc/resolv.conf )
          args+=( --bind-try /etc/nsswitch.conf /etc/nsswitch.conf )

          # --- TLS trust store (robust) ---
          # Provide hashed cert dir at /cacert (RO)
          args+=( --ro-bind "$CACERT_DIR" /cacert )

          # Provide common bundle file locations under /etc (writable tmpfs)
          args+=( --dir /etc/ssl )
          args+=( --dir /etc/ssl/certs )
          args+=( --ro-bind "$CACERT" /etc/ssl/cert.pem )
          args+=( --ro-bind "$CACERT" /etc/ssl/certs/ca-certificates.crt )

          # RHEL-ish location some stacks probe
          args+=( --dir /etc/pki )
          args+=( --dir /etc/pki/tls )
          args+=( --dir /etc/pki/tls/certs )
          args+=( --ro-bind "$CACERT" /etc/pki/tls/certs/ca-bundle.crt )

          # --- Workspace allowlist ---
          args+=( --bind "$SHARE" "$SHARE" )
          args+=( --chdir "$SHARE" )

          # Overlay the agent home workspace into the share workspace
          args+=( --dir "$SHARE/${aiShareWorkspace}" )
          args+=( --bind "$AGENT_HOME_WS" "$SHARE/${aiShareWorkspace}" )

          # Per-agent persistent state RW
          args+=( --bind "$AGENT_HOME" "$AGENT_HOME" )

          # --- Ensure agent home subdirs exist inside sandbox ---
          args+=( --dir "$AGENT_HOME/.config" )
          args+=( --dir "$AGENT_HOME/.cache" )
          args+=( --dir "$AGENT_HOME/.local" )
          args+=( --dir "$AGENT_HOME/.local/share" )
          args+=( --dir "$AGENT_HOME/.local/state" )

          # --- Agent tools ---
          args+=( --setenv SHELL "${pkgs.bashInteractive}/bin/bash" )
          args+=( --setenv PATH "$TOOLS" )
          args+=( --symlink "${pkgs.bashInteractive}/bin/bash" /bin/sh )

          # Provide /usr/bin/env so portable `#!/usr/bin/env <tool>` shebangs work
          # inside the sandbox (resolves the interpreter via the PATH set above,
          # e.g. `env bash`, `env python3`). Without this, exec of such scripts
          # fails with ENOENT ("No such file or directory").
          args+=( --symlink "${pkgs.coreutils}/bin/env" /usr/bin/env )

          # --- Agent secrets ---
          # args+=( --ro-bind-try "$HOME/.age-ai" "$AGENT_HOME/.age-ai" )
          #
          # --- Agent persistent home ---
          args+=( --setenv HOME "$AGENT_HOME" )
          args+=( --setenv XDG_CONFIG_HOME "$AGENT_HOME/.config" )
          args+=( --setenv XDG_CACHE_HOME  "$AGENT_HOME/.cache" )
          args+=( --setenv XDG_DATA_HOME   "$AGENT_HOME/.local/share" )
          args+=( --setenv XDG_STATE_HOME  "$AGENT_HOME/.local/state" )

          # --- Optional: read-only git config (NO creds) ---
          # Enables commit authorship inside the sandbox. Ensure your gitconfig
          # does not embed credentials (use credential helpers instead).
          # args+=( --ro-bind-try "$HOME/.gitconfig" "$AGENT_HOME/.gitconfig" )
          # args+=( --ro-bind-try "$HOME/.config/git" "$AGENT_HOME/.config/git" )

          # --- Nix config ---
          # netrc left out intentionally: clone from outside the sandbox and push manually.
          # args+=( --ro-bind-try /etc/nix/netrc "$AGENT_HOME/.config/nix/netrc" )
          args+=( --ro-bind-try /etc/nix/nix.conf "$AGENT_HOME/.config/nix/nix.conf" )

          # --- TLS env vars ---
          # SSL_CERT_DIR points at hashed directory; SSL_CERT_FILE at common file path
          args+=( --setenv SSL_CERT_DIR /cacert )
          args+=( --setenv SSL_CERT_FILE /etc/ssl/certs/ca-certificates.crt )
          args+=( --setenv NODE_EXTRA_CA_CERTS /etc/ssl/certs/ca-certificates.crt )

          # Avoid IPv6 blackhole
          args+=( --setenv NODE_OPTIONS --dns-result-order=ipv4first )

          # Terminal type for curses/TUI apps
          args+=( --setenv TERM "''${TERM:-xterm-256color}" )

          # --- Identity (needed by git, ssh, and various tools) ---
          [ -n "''${USER:-}" ]    && args+=( --setenv USER    "''${USER}" )
          [ -n "''${LOGNAME:-}" ] && args+=( --setenv LOGNAME "''${LOGNAME}" )

          # --- Optional secrets passthrough ---
          github_token_in_use=0
          [ -n "''${GITHUB_PERSONAL_ACCESS_TOKEN:-}" ] && github_token_in_use=1 && args+=( --setenv GITHUB_PERSONAL_ACCESS_TOKEN "''${GITHUB_PERSONAL_ACCESS_TOKEN}" )
          [ -z "''${GITHUB_PERSONAL_ACCESS_TOKEN:-}" ] && [ -n "''${GITHUB_TOKEN:-}" ] && github_token_in_use=1 && args+=( --setenv GITHUB_PERSONAL_ACCESS_TOKEN "''${GITHUB_TOKEN}" )

          if [ "$github_token_in_use" -eq 1 ]; then
            echo "Warning: a GitHub token is being passed into the AI bubblewrap container as GITHUB_PERSONAL_ACCESS_TOKEN." >&2
            sleep 3
          fi

          # --- Per-agent API key passthrough ---
          ${pkgs.lib.concatMapStrings (varName: ''
          [ -n "''${${varName}:-}" ] && args+=( --setenv ${varName} "''${${varName}}" )
          '') agentEnvVars}

          # Locale support
          args+=( --setenv LOCALE_ARCHIVE "${pkgs.glibcLocales}/lib/locale/locale-archive" )

          if [ "''${1:-}" = "--bash" ]; then
            shift
            exec bwrap "''${args[@]}" ${pkgs.bashInteractive}/bin/bash "$@"
          fi

          exec bwrap "''${args[@]}" ${agentWrapped}/bin/${wrappedName} "$@"
        '';
      };
  };

  environment.systemPackages = with pkgs; [
    # antigravity
    bubblewrap
    socat
  ];

  nixpkgs.config.allowUnfree = true;

  # Required by bubblewrap in a hardened profile
  security.unprivilegedUsernsClone = true;
}
