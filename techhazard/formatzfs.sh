#!/bin/bash
set -e

poolname=${poolname:-znixos}
debug="${debug:-""}"
[ "$debug" ] && set -x


## the actual zpool create is below
#
# zpool create        \
# -O atime=on         \ #
# -O relatime=on      \ # only write access time (requires atime, see man zfs)
# -O compression=lz4  \ # compress all the things! (man zfs)
# -O snapdir=visible  \ # ever so sligthly easier snap management (man zfs)
# -O xattr=sa         \ # selinux file permissions (man zfs)
# -o ashift=12        \ # 4k blocks (man zpool)
# -o altroot=/mnt     \ # temp mount during install (man zpool)
# "$poolname               \ # new name of the pool
# /dev/mapper/nixroot   # devices used in the pool (in my case one, so no mirror or raid)

zpool create        \
-O atime=on         \
-O relatime=on      \
-O compression=lz4  \
-O snapdir=visible  \
-O xattr=sa         \
-o ashift=12        \
-o altroot=/mnt     \
"$poolname"         \
/dev/mapper/nixroot \

# dataset for / (root)
zfs create -o mountpoint=none "$poolname/root"
echo created root dataset
zfs create -o mountpoint=legacy "$poolname/root/nixos"

zfs create -o mountpoint=legacy "$poolname/home"

# dataset for swap
mem_amount="$(grep MemTotal /proc/meminfo | awk '{print $2$3}')"
zfs create -o compression=off -V "${mem_amount}" "$poolname/swap"
mkswap -L SWAP "/dev/zvol/$poolname/swap"
swapon "/dev/zvol/$poolname/swap"

# mount the root dataset at /mnt
mount -t zfs "$poolname/root/nixos" /mnt

# mount the home datset at future /home
mkdir -p /mnt/home
mount -t zfs "$poolname/home" /mnt/home
# mount EFI partition at future /boot
mkdir -p /mnt/boot
mount  /dev/disk/by-partlabel/efiboot /mnt/boot

# set boot filesystem
zpool set bootfs="$poolname/root/nixos" "$poolname"

# enable auto snapshots for home dataset
# defaults to keeping:
# - 4 frequent snapshots (1 per 15m)
# - 24 hourly snapshots
# - 7 daily snapshots
# - 4 weekly snapshots
# - 12 monthly snapshots
zfs set com.sun:auto-snapshot=true "$poolname/home"
exit 0
