self: nixpkgs: {
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) getName hasPrefix mkEnableOption mkOption types mkIf;

  # This hack gives us a custom pkgs which allows jlink to be installed
  # without the user having to explicitly set all of these configuration options
  system = pkgs.stdenv.system;
  specialPkgs = import nixpkgs {
    inherit system;
    config.allowUnfreePredicate = pkg: (getName pkg == "segger-jlink");
    config.allowInsecurePredicate = pkg: (hasPrefix (getName pkg) "segger-jlink-qt4");
    config.segger-jlink.acceptLicense = true;
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
