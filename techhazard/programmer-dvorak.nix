# place this file in /etc/nixos/ and add
#     ./programmer-dvorak.nix
# to /etc/nixos/configuration.nix in `imports`
{config, pkgs, ...}:
{
  # TTY settings
  i18n = {
    # luckily this also changes the keyboard layout at boot (for e.g full disk encryption passwords)
    consoleKeyMap = "dvorak-programmer";
  };

  # GUI settings, this includes login screen
  services.xserver.layout = "us";
  services.xserver.xkbVariant = "dvp";
  services.xserver.xkbOptions = "eurosign:e";
}