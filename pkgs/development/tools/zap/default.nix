{ lib
, buildNpmPackage
, fetchFromGitHub
, electron_27-bin
, cypress
}:

buildNpmPackage rec {
  pname = "zcl-advanced-platform";
  version = "2024.01.20";

  src = fetchFromGitHub {
    owner = "project-chip";
    repo = "zap";
    rev = "v${version}";
    hash = "sha256-rqO7Rnt9dMVkytQQPB0JCUHApy0hapt+KjkKWd1CDvg=";
  };

  propagatedBuildInputs = [
    electron_27-bin
    cypress
  ];

  npmDepsHash = "sha256-L7y49Jr9JukHbuzhe3JqpAlKqQYHXKax2uM+RnNiF2o=";

  npmPackFlags = [ "--ignore-scripts" ];

  ELECTRON_SKIP_BINARY_DOWNLOAD = 1;
  CYPRESS_INSTALL_BINARY = 0;

  meta = with lib; {
    description = "A generation engine and user interface for applications and libraries based on the Zigbee Cluster Library.";
    homepage = "https://docs.silabs.com/zap-tool/1.0.0/zap-start/";
    license = licenses.asl20;
    maintainers = with maintainers; [ leonm1 ];
  };
}
