# Business profile packages — extends shared base with business-specific tools
# Common tools (CLI, fonts, editors, etc.) come from ../common/packages.nix
{ pkgs, ... }:

{
  imports = [ ../common/packages.nix ];

  environment.systemPackages = with pkgs; [
    # Remote support (tech admin connects via ID + password)
    rustdesk-flutter

    # Business-specific CLI
    less

    # Python for learning to code (business subset — no rich/pymupdf4llm)
    (python3.withPackages (ps: with ps; [
      pytest
      pydantic
      jinja2
    ]))
  ];
}
