build:
    nix-build . -A sendspin-cli
install:
    nix-env -i -f . -A sendspin-cli
