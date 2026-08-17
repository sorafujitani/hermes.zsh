{
  description = "Hermes, a Rust-native shell workflow suite for Zsh";

  inputs.nixpkgs.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0.1";

  outputs = { self, nixpkgs }:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          version = "0.1.0";
          hermes = pkgs.rustPlatform.buildRustPackage {
            pname = "hermes";
            inherit version;
            src = ./.;

            cargoLock = {
              lockFile = ./Cargo.lock;
            };

            postInstall = ''
              install -Dm644 hermes.zsh "$out/share/hermes/hermes.zsh"
              cp -R shells docs spec scripts "$out/share/hermes/"
            '';

            meta = {
              description = "Rust-native stateful shell workflows for Zsh";
              homepage = "https://github.com/sorafujitani/hermes.zsh";
              license = pkgs.lib.licenses.mit;
              mainProgram = "hermes";
              platforms = systems;
            };
          };

          hermesWithTools = pkgs.buildEnv {
            name = "hermes-${version}";
            paths = [ hermes pkgs.fzf pkgs.ghq ];
            pathsToLink = [ "/bin" "/share" ];
          };
        in {
          default = hermesWithTools;
          hermes = hermesWithTools;
          hermes-core = hermes;
        });

      apps = forAllSystems (system:
        let
          hermes = self.packages.${system}.hermes-core;
        in {
          default = {
            type = "app";
            program = "${hermes}/bin/hermes";
            meta.description = "Run Hermes from the Nix package";
          };
          hermes = {
            type = "app";
            program = "${hermes}/bin/hermes";
            meta.description = "Run Hermes from the Nix package";
          };
        });

      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in {
          default = pkgs.mkShell {
            packages = [
              pkgs.cargo
              pkgs.fzf
              pkgs.ghq
              pkgs.git
              pkgs.jq
              pkgs.rustc
              pkgs.sqlite
              pkgs.zsh
            ];
          };
        });
    };
}
