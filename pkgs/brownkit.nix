{ lib
, python3Packages
, fetchFromGitHub ? null
,
}:

python3Packages.buildPythonApplication rec {
  pname = "brownkit";
  version = "0.2.1";
  format = "pyproject";

  # Use local source directory
  src = /home/guyfawkes/brownkit;

  nativeBuildInputs = with python3Packages; [
    setuptools
    wheel
  ];

  propagatedBuildInputs = with python3Packages; [
    click
    pyyaml
    jinja2
    rich
  ];

  # Skip tests during build (can be enabled later)
  doCheck = false;

  meta = with lib; {
    description = "AI-driven workflow for transitioning brownfield codebases to Speckit-ready state";
    homepage = "https://github.com/brownkit/brownkit";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "brownfield";
  };
}
