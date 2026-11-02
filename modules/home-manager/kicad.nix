{ pkgs, ... }:
let
  # Not in nixpkgs; only needed by the MCP server's schematic tools.
  kicad-skip = pkgs.python3Packages.buildPythonPackage rec {
    pname = "kicad-skip";
    version = "0.2.5";
    pyproject = true;
    src = pkgs.python3Packages.fetchPypi {
      pname = "kicad-skip";
      inherit version;
      hash = "sha256-3GtHIV2h6C8syFZ/Dx6OWsgpf14ZQdlnGS4EM4DgjIM=";
    };
    build-system = [ pkgs.python3Packages.setuptools ];
    dependencies = [ pkgs.python3Packages.sexpdata ];
    doCheck = false;
  };

  # Python with KiCad's pcbnew bindings, which the server shells out to.
  python = pkgs.python3.withPackages (ps: [
    ps.kicad
    ps.kicad-python
    ps.sexpdata
    ps.pillow
    ps.pymupdf
    ps.cairosvg
    ps.colorlog
    ps.pydantic
    ps.requests
    ps.python-dotenv
    kicad-skip
  ]);

  # mixelpixx/KiCAD-MCP-Server: AI-assisted PCB design over MCP.
  kicad-mcp = pkgs.buildNpmPackage {
    pname = "kicad-mcp";
    version = "2.8.3";
    src = pkgs.fetchFromGitHub {
      owner = "mixelpixx";
      repo = "KiCAD-MCP-Server";
      rev = "628d320f4cd51b51e55489fd6f29f20c228e2741";
      hash = "sha256-dsZHxH659uvxCGYwgXcfIwXUH3wgwkR/hhBcRShP5bo=";
    };
    npmDepsHash = "sha256-QWGd2FQhn7uvYTPb7zF3qkIO2s/lQPQDl5kDkvKY17Q=";
    nativeBuildInputs = [ pkgs.makeWrapper ];

    # The server resolves python/ relative to dist/, so ship the whole tree.
    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/kicad-mcp
      cp -r dist python resources config node_modules package.json $out/lib/kicad-mcp/
      makeWrapper ${pkgs.nodejs}/bin/node $out/bin/kicad-mcp \
        --add-flags $out/lib/kicad-mcp/dist/index.js \
        --set KICAD_PYTHON ${python}/bin/python3
      runHook postInstall
    '';
  };
in
{
  programs.mcp.servers.kicad.command = "${kicad-mcp}/bin/kicad-mcp";

  home.packages = [
    pkgs.kicad
    kicad-mcp
  ];
}
