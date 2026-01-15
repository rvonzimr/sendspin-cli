{
  pkgs ?
    import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixpkgs-unstable.tar.gz")
      {
        overlays = [
          (self: super: {
          })
        ];
      },
}:

let
  pythonPackages = pkgs.python314Packages;
  aiosendspin = pythonPackages.callPackage ./aiosendspin.nix { };
in
{
  sendspin-cli = pythonPackages.callPackage ./sendspin.nix { inherit aiosendspin; };
}
