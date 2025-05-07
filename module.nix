self: nixpkgs: {
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) getName mkEnableOption mkOption types mkIf;

  system = pkgs.stdenv.system;
  specialPkgs = import nixpkgs {
    inherit system;
    config.allowUnfreePredicate = pkg: (getName pkg == "segger-jlink");
  };

  cfg = config.programs.jlink;
in {
  options = {
    programs.jlink = {
      enable = mkEnableOption "J-Link device support";
      trustedUsers = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          List of users that are allowed to interact with J-Link devices.
          Users will be added to the "dialout" group.
        '';
      };
    };
  };

  config = mkIf cfg.enable (let
    jlink = specialPkgs.segger-jlink;
  in {
    environment.systemPackages = [jlink];
    # Enable udev rules so non-root users can access the J-Link device
    services.udev.packages = [jlink];

    # Allow trusted users to access the J-Link device
    # by adding them to the "dialout" group
    users.users = builtins.listToAttrs (map (user: {
        name = user;
        value = {
          extraGroups = ["dialout"];
        };
      })
      cfg.trustedUsers);
  });
}
