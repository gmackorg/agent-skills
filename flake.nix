{
  description = "Reference implementation of an agent-skills repo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      lib = nixpkgs.lib;
      supportedSystems = [ "aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux" ];

      skillDirs = lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./skills);
      toolDirs = lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./tools);
      agentDirs = lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./agents);

      metadataPaths =
        lib.mapAttrsToList
          (name: _: {
            inherit name;
            path = ./skills + "/${name}/skill.json";
          })
          (lib.filterAttrs
            (name: _: builtins.pathExists (./skills + "/${name}/skill.json"))
            skillDirs);

      skillMetadata =
        builtins.listToAttrs
          (map
            (item: {
              name = item.name;
              value = builtins.fromJSON (builtins.readFile item.path);
            })
            metadataPaths);

      toolMetadataPaths =
        lib.mapAttrsToList
          (name: _: {
            inherit name;
            path = ./tools + "/${name}/tool.json";
          })
          (lib.filterAttrs
            (name: _: builtins.pathExists (./tools + "/${name}/tool.json"))
            toolDirs);

      toolMetadata =
        builtins.listToAttrs
          (map
            (item: {
              name = item.name;
              value = builtins.fromJSON (builtins.readFile item.path);
            })
            toolMetadataPaths);

      agentMetadataPaths =
        lib.mapAttrsToList
          (name: _: {
            inherit name;
            path = ./agents + "/${name}/agent-metadata.json";
          })
          (lib.filterAttrs
            (name: _: builtins.pathExists (./agents + "/${name}/agent-metadata.json"))
            agentDirs);

      agentMetadata =
        builtins.listToAttrs
          (map
            (item: {
              name = item.name;
              value = builtins.fromJSON (builtins.readFile item.path);
            })
            agentMetadataPaths);
    in
    {
      inherit skillMetadata toolMetadata agentMetadata;

      homeManagerModules.default = import ./nix/home-manager-module.nix { inherit self inputs; };

      openclawPlugin = {
        name = "agent-skills-reference";
        skills = [
          ./skills/example-reference-skill
          ./skills/reference-layout-audit
        ];
        packages = [ ];
        needs = {
          stateDirs = [
            ".local/share/agent-skills"
          ];
          requiredEnv = [ ];
        };
      };

      packages = lib.genAttrs supportedSystems
        (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
          in
          builtins.listToAttrs
            (map
              (tool:
                {
                  name = tool.id;
                  value = pkgs.writeShellApplication {
                    name = tool.packageName;
                    runtimeInputs = map (pkgName: pkgs.${pkgName}) (tool.runtimePackages or []);
                    text = builtins.readFile (self + "/${tool.entrypoint}");
                  };
                })
              (builtins.attrValues toolMetadata)));

      formatter = lib.genAttrs supportedSystems
        (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
    };
}
