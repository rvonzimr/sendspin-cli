# default.nix
{
  pkgs ? import <nixpkgs> { },
}:

{
  CASetupUtility = pkgs.callPackage ./package.nix { };
}
