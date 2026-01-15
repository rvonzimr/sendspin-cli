{
  lib,
  buildPythonPackage,
  python,
  fetchPypi,

  # Dependencies
  aiohttp,
  av,
  mashumaro,
  orjson,
  pillow,
  zeroconf,
}:

buildPythonPackage rec {
  pname = "aiosendspin";
  version = "2.0.1";
  format = "pyproject";
  doCheck = false;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ZDy83LUZjYJz9eg7vEbM/938ReHIuex0uM3iNABkwyI=";
  };

  buildInputs = [
  ];

  nativeBuildInputs = [
    python.pkgs.setuptools-scm
  ];

  propagatedBuildInputs = [
    aiohttp
    av
    mashumaro
    orjson
    pillow
    zeroconf
  ];

  meta = with lib; {
    description = "Async Python implementation of the Sendspin Protocol.";
    homepage = "https://github.com/Sendspin/aiosendspin";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };
}
