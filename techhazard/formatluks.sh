#!/bin/bash
set -e

debug="${debug:-""}"
[ "$debug" ] && set -x

use_passphrase="${use_passphrase:-"yes"}"
passphrase="${passphrase:-NONE}"
keyfile="${keyfile:-NONE}"
keysize="${keysize:-4096}"

# temporary keyfile, will be removed (8k, ridiculously large)
dd if=/dev/urandom of=/tmp/keyfile bs=1k count=8
## now we encrypt the second partition
# pick a strong passphrase

echo "Creating the encrypted partition, follow the instructions and use a strong passphrase!"
# formats the partition with luks and adds the temporary keyfile.
echo "YES" | cryptsetup luksFormat /dev/disk/by-partlabel/cryptroot --key-size 512 --hash sha512 --key-file /tmp/keyfile
if [[ $use_passphrase != "no" ]];
then
	# sets the given passphrase or asks for one
	if [[ "${passphrase}" != "NONE" ]];
	then
		echo "$passphrase" | cryptsetup luksAddKey /dev/disk/by-partlabel/cryptroot --key-file /tmp/keyfile
	else
		cryptsetup luksAddKey /dev/disk/by-partlabel/cryptroot --key-file /tmp/keyfile
	fi
	echo "added passphrase"
fi


if [[ "${keyfile}" != "NONE" ]];
then
	cryptsetup luksAddKey /dev/disk/by-partlabel/cryptroot  -d /tmp/keyfile --new-keyfile-size="${keysize}" "${keyfile}"
	echo "added keyfile"
fi


# mount the cryptdisk at /dev/mapper/nixroot
cryptsetup luksOpen /dev/disk/by-partlabel/cryptroot nixroot -d /tmp/keyfile
# remove the temporary keyfile
cryptsetup luksRemoveKey /dev/disk/by-partlabel/cryptroot /tmp/keyfile
rm -f /tmp/keyfile
exit 0
