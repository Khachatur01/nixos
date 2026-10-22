# Claude Code against a locally served model, with no API calls leaving the
# machine. The flake owns the ollama service: its module enables
# services.ollama and sets the server environment the agent depends on
# (24h keep-alive, two resident models, q8_0 KV), which only works if those
# values live in exactly one place.
#
# The input is a local path, so the repo has to be mounted at rebuild time.
{
  inputs,
  pkgs,
  ...
}:

{
  imports = [ inputs.local-ai-agent.nixosModules.default ];

  services.local-ai-agent = {
    enable = true;

    # Prebuilt CUDA build, from the cache.nixos-cuda.org substituter in
    # modules/nixos/nix.nix. On the CPU default the 35B offloads nothing.
    ollamaPackage = pkgs.ollama-cuda;
  };
}
