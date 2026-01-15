{
  lib,
  python,
  fetchPypi,

  # dependencies
  aiosendspin,
  av,
  numpy,
  qrcode,
  readchar,
  rich,
  sounddevice,
}:

python.pkgs.buildPythonApplication rec {
  pname = "sendspin";
  version = "2.1.1";
  format = "pyproject";
  doCheck = false;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-D2GHbdm+vEycof+aYvDeQsbRHtgHoX9Qt/EkJmmNzfM=";
  };

  nativeBuildInputs = [
    python.pkgs.setuptools-scm
  ];

  propagatedBuildInputs = [
    aiosendspin
    av
    numpy
    qrcode
    readchar
    rich
    sounddevice
  ];

  meta = with lib; {
    changelog = "https://github.com/pytest-dev/pytest/releases/tag/${version}";
    description = "Synchronized audio player for Sendspin servers";
    homepage = "https://github.com/Sendspin/sendspin-cli";
    license = licenses.asl20;
    maintainers = with maintainers; [
      #balloob
      #maximman345
      #rvonzimr
    ];
  };
}
