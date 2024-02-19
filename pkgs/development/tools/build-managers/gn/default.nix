{ callPackage, ... } @ args:

callPackage ./generic.nix args {
  # Note: Please use the recommended version for Chromium, e.g.:
  # https://git.archlinux.org/svntogit/packages.git/tree/trunk/chromium-gn-version.sh?h=packages/gn
  rev = "8b973aa51d02aa1ab327100007d4070c24b862b0";
  revNum = "2145"; # git describe HEAD --match initial-commit | cut -d- -f3
  version = "2024-02-15";
  sha256 = "sha256-SD4IJFPsJoMqVCXfzlcdzBwszBxm1mgsw82GimUP9yo=";
}
