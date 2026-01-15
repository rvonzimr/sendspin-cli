{
  description = "A flake for the sendspin-cli application";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      overlay =
        final: prev:
        let
          # These tests were failing when building for aarch64-linux :shruggg:
          python-overlay = py-final: py-prev: {
            ipython = py-prev.ipython.overridePythonAttrs (oldAttrs: {
              doCheck = false;
            });
            "proxy-py" = py-prev."proxy-py".overridePythonAttrs (oldAttrs: {
              doCheck = false;
            });
            aiohttp = py-prev.aiohttp.overridePythonAttrs (oldAttrs: {
              doCheck = false;
            });
          };

          pythonPackages = prev.python312Packages.overrideScope python-overlay;
        in
        {
          aiosendspin = pythonPackages.callPackage ./aiosendspin.nix {
          };
          sendspin = pythonPackages.callPackage ./sendspin.nix {
            aiosendspin = final.aiosendspin;
          };
        };
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlay ];
          };
        in
        {
          inherit (pkgs) aiosendspin sendspin;
          default = pkgs.sendspin;
        }
      );

      defaultPackage = forAllSystems (system: self.packages.${system}.default);

      nixosModules.default =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let
          cfg = config.services.sendspin;
        in
        {
          options.services.sendspin = {
            enable = lib.mkEnableOption "the sendspin daemon";

            clientName = lib.mkOption {
              type = lib.types.str;
              default = "rpi-sendspin-client";
              description = "Client name for the sendspin daemon.";
            };

            audioDevice = lib.mkOption {
              type = with lib.types; nullOr str;
              default = null;
              example = "1";
              description = "Audio device for the sendspin daemon. see: list-audio-devices"; 
            };

            staticDelayMs = lib.mkOption {
              type = lib.types.int;
              default = 0;
              description = "Static delay in milliseconds.";
            };
          };

          # Largely adapted from the repo's install script.
          config = lib.mkIf cfg.enable {
            systemd.services.sendspin = {
              description = "Sendspin Daemon";
              wantedBy = [ "multi-user.target" ];
              after = [ "network.target" "sound.target" ];
              script = ''
                exec ${self.packages.${pkgs.system}.default}/bin/sendspin daemon \
                  ''${SENDSPIN_CLIENT_NAME:+--name "$SENDSPIN_CLIENT_NAME"} \
                  ''${SENDSPIN_AUDIO_DEVICE:+--audio-device "$SENDSPIN_AUDIO_DEVICE"} \
                  --static-delay-ms ''${SENDSPIN_STATIC_DELAY_MS:-0} \
                  ''${SENDSPIN_ARGS}
              '';
              serviceConfig = {
                Type = "simple";
                DynamicUser = true;
                SupplementaryGroups = [ "audio" ];
                Environment = [
                  "SENDSPIN_CLIENT_NAME=${cfg.clientName}"
                  "SENDSPIN_STATIC_DELAY_MS=${toString cfg.staticDelayMs}"
                ]
                ++ (lib.optional (cfg.audioDevice != null) "SENDSPIN_AUDIO_DEVICE=${cfg.audioDevice}");
                Restart = "on-failure";
                RestartSec = "10s";
                StandardOutput = "journal";
                StandardError = "journal";
                NoNewPrivileges = true;
                PrivateTmp = true;
                ProtectSystem = "strict";
                ProtectHome = "read-only";
              };
            };

            environment.systemPackages = [ self.packages.${pkgs.system}.default ];
          };
        };
    };
}
