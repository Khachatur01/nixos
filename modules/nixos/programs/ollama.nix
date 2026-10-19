# CPU build by default; hosts with a GPU override services.ollama.package
# (e.g. pkgs.ollama-cuda or pkgs.ollama-rocm).
{
  services.ollama.enable = true;
}
