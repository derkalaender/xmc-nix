# xmc-nix
Shell and NixOS module for the XMC Toolchain.

> [!IMPORTANT]
> I have created this for and tested it on a [flake](https://nixos-and-flakes.thiscute.world/)-based system only! Feel free to open a PR for adding non-flake compatibility.

## How To Install J-Link (Module)
This flake offers a convience module for installing J-Link. Because J-Link is unfree, very old and insecure (it uses QT4 which has [many CVEs](https://github.com/NixOS/nixpkgs/blob/1d3aeb5a193b9ff13f63f4d9cc169fb88129f860/pkgs/by-name/se/segger-jlink/qt4-bundled.nix#L48-L71)), it usually cannot be installed without a few configuration options. By using this module, all of that will be handled for you.

Add this flake as an input and make sure it follows your nixpkgs input
```nix
xmc-nix.url = "github:derkalaender/xmc-nix";
xmc-nix.inputs.nixpkgs.follows = "nixpkgs";
```

Then, import the J-Link module as you'd usually do
```nix
imports = [
  xmc-nix.nixosModules.jlink
]
```

Finally, activate the J-Link support in your config
```nix
programs.jlink = {
  enable = true;
  trustedUsers = [ "me" ];
};
```
The `trustedUsers` option allows specifying which users should be added to the `dialout` group. Any user in this group can access the J-Link device (e.g. flash it) without root permissions.


## How To Build/Flash Programs (Shell)
> [!IMPORTANT]
> The shell doesn't come with J-Link as it requires special configuration as explained in the previous section. So, be sure to enable the module as well!

This flake packages the XMC Library (xmclib) based on the `.deb` file.

You can acquire a development shell with the xmclib, ARM cross-compiler and all other necessary tools by simply invoking
```nix
nix develop github:derkalaender/xmc-nix
```
This will populate your environment with the necessary tools and set the environment variable `XMC_LIBDIR` to the path of the xmclib. Remove any hard-coded path or explicit setting of `XMC_LIBDIR` in your build system (e.g. Makefile).

For better convience, use [direnv](https://github.com/direnv/direnv) with the [nix-direnv](https://github.com/nix-community/nix-direnv) implementation to automatically spawn the dev shell. For this, create a `.envrc` file in your project directory like so
```
use flake github:derkalaender/xmc-nix
```
and run
```bash
direnv allow
```
once.


> [!TIP]
> Alternatively, although not recommended, you can install all the required tools manually system-wide. For xmclib, this flake exposes `legacyPackages.${system}.xmclib`.
