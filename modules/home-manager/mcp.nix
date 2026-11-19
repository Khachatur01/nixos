{ ... }:
{
  # Shared MCP servers (see freecad.nix, kicad.nix) injected into
  # every agent module.
  programs.mcp.enable = true;
  programs.claude-code.enableMcpIntegration = true;
  programs.opencode.enableMcpIntegration = true;
}
