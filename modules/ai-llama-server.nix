# Local llama.cpp LLM server with CUDA offload.
#
# Imported per-machine with the GPU's CUDA architecture list, e.g.:
#   (import ../modules/ai-llama-server.nix {cudaArchitectures = "61";})
# Find a GPU's value with: nvidia-smi --query-gpu=compute_cap --format=csv
#
# The explicit architecture list matters: the nixpkgs default CUDA capability
# set on this pin starts at 7.5 (Turing), so older GPUs like Pascal get no
# kernels at all from a plain `cudaSupport = true` build.
{cudaArchitectures}: {
  lib,
  pkgs,
  ...
}: let
  # Pin the CUDA 12 package set rather than follow the nixpkgs default:
  # Pascal (p71's Quadro P3000) was dropped from CUDA 13, and CUDA 12.9
  # still supports everything Turing+ so newer GPUs lose nothing.
  llamaCpp =
    (pkgs.llama-cpp.override {
      cudaSupport = true;
      cudaPackages = pkgs.cudaPackages_12;
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
in {
  # OpenAI-compatible API at http://127.0.0.1:8012/v1 (chat completions,
  # completions, embeddings) plus a built-in web UI at the root path.
  services.llama-cpp = {
    enable = true;
    package = llamaCpp;
    inherit model;
    port = 8012;

    extraFlags = [
      # Full GPU offload; keeps the KV cache in VRAM too.
      "--n-gpu-layers"
      "99"
      "--ctx-size"
      "8192"

      # Use the chat template embedded in the GGUF.
      "--jinja"

      # Conservative default for faithful edit/cleanup style tasks; clients
      # can still override per-request.
      "--temp"
      "0.3"
    ];
  };

  # CUDA context creation maps writable+executable memory inside libcuda,
  # which the upstream module's hardening rejects, leaving the server unable
  # to see the GPU.
  systemd.services.llama-cpp.serviceConfig.MemoryDenyWriteExecute = lib.mkForce false;

  # llama-cli/llama-bench from the same CUDA build for smoke tests, e.g.:
  #   llama-bench -m $MODEL -ngl 99
  environment.systemPackages = [llamaCpp];
}
