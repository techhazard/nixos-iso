#!/bin/bash
# This partitions the given rootdisk into two partitions: one for EFI (300MB) and the rest for LUKS (which will contain ZFS)
# This then formats the resulting EFI partition with FAT32

set -e
## The actual command is below the comment block.
# we will create a new GPT table
#
# o:         create new GPT table
#         y: confirm creation
#
# with the new partition table,
# we now create the EFI partition
#
# n:         create new partion
#         1: partition number
#      2048: start position
#     +300M: make it 300MB big
#      ef00: set an EFI partition type
#
# With the EFI partition, we
# use the rest of the disk for LUKS
#
# n:         create new partition
#         2: partition number
#   <empty>: start partition right after first
#   <empty>: use all remaining space
#      8300: set generic linux partition type
#
# We only need to set the partition labels 
#
# c:         change partition label
#         1: partition to label
#   efiboot: name of the partition
# c:         change partition label
#         2: partition to label
# cryptroot: name of the partition
# 
# w:	     write changes and quit
#         y: confirm write
[ $debug ] && echo p1
gdisk ${rootdisk} >/dev/null <<end_of_commands
o
y
n
1
2048
+300M
ef00
n
2


8300
c
1
efiboot
c
2
cryptroot
w
y
end_of_commands
[ $debug ] && echo p2

# check for the newly created partitions
# this sometimes gives unrelated errors
# so we change it to  `partprobe || true`
partprobe "${rootdisk}" >/dev/null || true
[ $debug ] && echo p3
# wait for label to show up
while [[ ! -e /dev/disk/by-partlabel/efiboot ]];
do
	sleep 2;
done
[ $debug ] && echo p4
# wait for label to show up
while [[ ! -e /dev/disk/by-partlabel/cryptroot ]];
do
	sleep 2;
done
[ $debug ] && echo p5
# check if both labels exist
ls /dev/disk/by-partlabel/efiboot   >/dev/null
ls /dev/disk/by-partlabel/cryptroot >/dev/null
[ $debug ] && echo p6
## format the EFI partition
mkfs.vfat /dev/disk/by-partlabel/efiboot
[ $debug ] && echo p7
exit 0
