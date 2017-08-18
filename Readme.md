# NixOS with ZFS on LUKS

After some effort (and asking for help on the nix-dev mailing list) I 
installed ZFS on an encrypted partition. The relevant configuration is
below.

- [Installing](#installing)
  - [Use keyfile](#use-keyfile)
  - [Configure passphrase](#configure-passphrase)
  - [Configure without passphrase](#configure-without-passphrase)
- [Misc commands](#misc-commands) 
- [To Do](#to-do)
- [Resources I used](#resources-i-used)
- [Installing with old script](#installing-with-old-script)

## Installing
*I do not have a custom iso yet, so you'll need two USBs. One for the NixOS iso, and one for these files. You'll have to mount the second stick manually.*

1. Boot into the nixos environment and find the uuid or id of the disk you want to install to. Do not use `/dev/sda` but `/dev/disk/by-...`, use `lsblk` and `blkid`.
2. export it to the environment as `rootdisk`:
```sh
# whole disk please, no partition
export rootdisk="/dev/disk/by-id/ata-Some-Storage-Device"
```
3. [use keyfile](#use-keyfile) and/or [configure passphrase](#configure-passphrase) usage (see sections below)
4. run it:
```sh
bash /path/to/automated_install.sh
```
### Use keyfile
It is possible to use a keyfile (e.g. on a usb stick). If you want a keyfile and not have a passphrase for backup, see [Configure without passphrase](#configure-without-passphrase) below.
```sh
# part of step 3
export keyfile="/dev/disk/by-id/usb-Some-Usb-Stick"
# optional, default is 4096
export keysize="8192"
```
### Configure passphrase
It is possible to pass the passphrase in an environment variable to make the install fully automated. This is generally unwise, but since we are in a temporary live enviorment I consider it safe enough. You can also put it as `passphrase="your passphrase here"` in `automated_install.sh` on line `16` instead.
If you add a keyfile as well, both are added.
```sh
# part of step 3
export passphrase="your passphrase here"
```
### Configure without passphrase
If you only want to add a keyfile and not set a passphrase, set `use_passphrase` to `no`. This is not recommended.
```sh
# part of step 3
export use_passphrase="no"
# see Use keyfile above
export keyfile="/path/to/keyfile"
```

## Misc commands
I always run these command right after booting the install usb.
```sh
# I use programmer dvorak instead of qwerty
loadkeys dvorak-programmer
```

## To Do 
- [ ] use nixos-rebuild to make an iso containing the files
- [ ] customise the iso with ZFS support and these files
- [ ] find the location of `automated_install.sh` in the built iso.

## Resources I used
I used the following resources:  
- https://nixos.org/wiki/ZFS_on_NixOS#How_to_install_NixOS_on_a_ZFS_root_filesystem
- https://nixos.org/wiki/Encrypted_Root_on_NixOS
- http://www.pavelkogan.com/2014/05/23/luks-full-disk-encryption/
- https://wiki.archlinux.org/index.php/PCI_passthrough_via_OVMF
- https://github.com/zfsonlinux/zfs/wiki/Ubuntu-16.10-Root-on-ZFS

## Installing with old script
use this version of the files: [old version](https://gist.github.com/awesomefireduck/c763e168a62a0ef559a1fb9473261459/a92e653ae949972d12738a1f7e042eceb832dadf). All text below is about those versions, not the ones you see here.

The commands in `init.sh` I run manually, (so no sed :-P)

The `zfscreate.sh` is used to set up a single-disk ZFS root filesystem inside of an encrypted LUKS container.

The two `*.nix` files have the minimum config needed for this (compare them with the generated ones in `/mnt/etc/nixos/`); The UUIDs should be filled-in by `nixos-generate-config`; 
the `"usb_storage"` addition is not needed for everyone, just like the `keyfile` options; the other important changes
are the `hostId`, which is required by ZFS; and the `boot.supportedFilesystems` which I'm not even sure of if that's necessary
