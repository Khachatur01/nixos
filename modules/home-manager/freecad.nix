{ pkgs, inputs, ... }:
let
  freecad-mcp = pkgs.python3Packages.buildPythonApplication {
    pname = "freecad-mcp";
    version = "git-${inputs.freecad-mcp.shortRev or "dirty"}";
    src = inputs.freecad-mcp;
    pyproject = true;

    build-system = [ pkgs.python3Packages.hatchling ];
    dependencies = with pkgs.python3Packages; [
      anyio
      certifi
      mcp
      pyjwt
      validators
    ];
    pythonRelaxDeps = true;
    doCheck = false;
  };
in
{
  home.packages = [
    pkgs.freecad
    freecad-mcp
  ];

  # FreeCAD-side RPC server addon the MCP server talks to.
  home.file.".local/share/FreeCAD/Mod/FreeCADMCP".source = "${inputs.freecad-mcp}/addon/FreeCADMCP";

  programs.mcp.servers.freecad = {
    command = "${freecad-mcp}/bin/freecad-mcp";
  };
}
