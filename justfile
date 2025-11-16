build:
    nix-build . -A CASetupUtility
install:
    nix-env -i -f . -A CASetupUtility
