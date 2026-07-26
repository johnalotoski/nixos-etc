# Local llama.cpp LLM server with CUDA offload.
#
# Imported per-machine with the GPU's CUDA architecture list, e.g.:
#   (import ../modules/ai-llama-server.nix {cudaArchitectures = "61";})
# Find a GPU's value with: nvidia-smi --query-gpu=compute_cap --format=csv
#
# The explicit architecture list matters: the nixpkgs default CUDA capability
# set on this pin starts at 7.5 (Turing), so older GPUs like Pascal get no
# kernels at all from a plain `cudaSupport = true` build.
#
# cudaPackages is per-machine for the same reason, because one shared pin no
# longer fits everyone. Per nixpkgs' own capability table
# (pkgs/development/cuda-modules/_cuda/db/bootstrap/cuda.nix):
#   - Pascal (6.1)    max 12.9  -- dropped in CUDA 13, so p71 is at its ceiling
#   - Ada (8.9)       min 11.8, no max
#   - Blackwell (12.0) min 12.8, no max
# Holding everyone at 12.9 to accommodate p71 would cost the newer cards a
# major version for no benefit. Note p71's ceiling is load-bearing: whenever
# nixpkgs drops the 12.x set, that machine loses CUDA llama.cpp entirely and
# will need a CPU build or a different GPU.
{
  cudaArchitectures,
  # Attribute name in pkgs, e.g. "cudaPackages_12" / "cudaPackages_13".
  cudaPackages ? "cudaPackages_12",
  # VRAM budget. The defaults are sized for the 6 GB cards; machines with more
  # headroom override them at import.
  ctxSize ? 8192,
  quantizeKvCache ? false,
  # Adds the `llm-heavy` command: a second, much larger model run on demand
  # rather than as a service. See the comment on heavyModelFile below for why
  # it is not simply a second resident server. Needs an 8 GB card.
  heavyModel ? false,
  heavyCtxSize ? 24576,
}: {
  lib,
  pkgs,
  ...
}: let
  llamaCpp =
    (pkgs.llama-cpp.override {
      cudaSupport = true;
      cudaPackages = pkgs.${cudaPackages};
    }).overrideAttrs (old: {
      # The last -DCMAKE_CUDA_ARCHITECTURES wins over the one the package
      # sets from the nixpkgs default capability list.
      cmakeFlags = (old.cmakeFlags or []) ++ ["-DCMAKE_CUDA_ARCHITECTURES=${cudaArchitectures}"];
    });

  # Qwen3-4B-Instruct-2507 Q4_K_M, ~2.4 GB: weights plus an 8k KV cache fully
  # offload into even the P3000's 6 GB VRAM, so system RAM impact is minimal.
  # The unsloth mirror is used because Qwen's official GGUF repo is
  # auth-gated; the hash matches the upstream LFS object.
  model = pkgs.fetchurl {
    url = "https://huggingface.co/unsloth/Qwen3-4B-Instruct-2507-GGUF/resolve/main/Qwen3-4B-Instruct-2507-Q4_K_M.gguf";
    hash = "sha256-NgWAO5gstkrq1E9sGyrjbjrNtB2ORsipTGUzvExn5Zc=";
  };

  port = 8012;

  # Ornith-1.0-9B Q4_K_M, ~5.3 GiB: a coding/agentic model for reviewing
  # sensitive code locally. Two reasons it is on demand rather than resident:
  #
  #  1. VRAM. 2.4 + 5.3 GiB of weights overruns an 8 GB card before any KV
  #     cache. Run alone it gets the whole GPU, so ~24k of q8_0 cache fits
  #     instead of the ~8k it would be squeezed into as a second server.
  #  2. Its reasoning block is always on and cannot be disabled, which is the
  #     wrong trade for the resident server's job (fast dictation cleanup).
  heavyModelFile = pkgs.fetchurl {
    url = "https://huggingface.co/deepreinforce-ai/Ornith-1.0-9B-GGUF/resolve/main/ornith-1.0-9b-Q4_K_M.gguf";
    hash = "sha256-VyDR9nG0mWSBJ0//4Bhow8Nuh8E1zIU4RxzHvWCHsQY=";
  };

  # Swaps the resident model out for the heavy one for the duration of a
  # session, on the same port so existing clients need no reconfiguration.
  llmHeavy = pkgs.writeShellApplication {
    name = "llm-heavy";
    runtimeInputs = [llamaCpp];
    text = ''
      # The store copy of sudo is not setuid; the NixOS wrapper is.
      sudo=/run/wrappers/bin/sudo

      echo "llm-heavy: stopping the resident llama-cpp to free VRAM ..."
      "$sudo" systemctl stop llama-cpp

      restore() {
        echo
        echo "llm-heavy: restoring the resident llama-cpp ..."
        "$sudo" systemctl start llama-cpp
      }
      trap restore EXIT

      echo "llm-heavy: Ornith-1.0-9B on http://127.0.0.1:${toString port} -- ctrl-c to switch back"
      llama-server \
        --model ${heavyModelFile} \
        --host 127.0.0.1 \
        --port ${toString port} \
        --n-gpu-layers 99 \
        --ctx-size ${toString heavyCtxSize} \
        --cache-type-k q8_0 \
        --cache-type-v q8_0 \
        --jinja \
        "$@"
    '';
  };
in {
  # OpenAI-compatible API at http://127.0.0.1:8012/v1 (chat completions,
  # completions, embeddings) plus a built-in web UI at the root path.
  services.llama-cpp = {
    enable = true;
    package = llamaCpp;
    inherit model port;

    extraFlags =
      [
        # Full GPU offload; keeps the KV cache in VRAM too.
        "--n-gpu-layers"
        "99"
        "--ctx-size"
        (toString ctxSize)

        # Use the chat template embedded in the GGUF.
        "--jinja"

        # Conservative default for faithful edit/cleanup style tasks; clients
        # can still override per-request.
        "--temp"
        "0.3"
      ]
      ++ lib.optionals quantizeKvCache [
        # Halves KV cache VRAM for negligible quality loss, roughly doubling
        # the context that fits. Needs flash attention, which this llama.cpp
        # defaults to `auto` and turns on for CUDA; if the server ever objects
        # that a quantized V cache requires it, add "--flash-attn" "on" here.
        "--cache-type-k"
        "q8_0"
        "--cache-type-v"
        "q8_0"
      ];
  };

  # CUDA context creation maps writable+executable memory inside libcuda,
  # which the upstream module's hardening rejects, leaving the server unable
  # to see the GPU.
  systemd.services.llama-cpp.serviceConfig.MemoryDenyWriteExecute = lib.mkForce false;

  # llama-cli/llama-bench from the same CUDA build for smoke tests, e.g.:
  #   llama-bench -m $MODEL -ngl 99
  environment.systemPackages = [llamaCpp] ++ lib.optional heavyModel llmHeavy;
}
