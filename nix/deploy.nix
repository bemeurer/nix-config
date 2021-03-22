{ self
, deploy-rs
, home-manager
, impermanence
, nixpkgs
, sops-nix
, ...
}@inputs:
let
  inherit (nixpkgs.lib) foldl' foldr;
  inherit (builtins) elemAt mapAttrs;

  mkHost = name: system: import ./mk-host.nix { inherit inputs name system; };

  mkPath = name: system: deploy-rs.lib.${system}.activate.nixos (mkHost name system);
in
{
  deploy = {
    autoRollback = true;
    magicRollback = true;
    user = "root";
    nodes = mapAttrs
      (n: v: {
        inherit (v) hostname;
        profiles.system.path = mkPath n v.system;
      })
      (import ./hosts.nix);
  };

  checks = mapAttrs (_: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
}
