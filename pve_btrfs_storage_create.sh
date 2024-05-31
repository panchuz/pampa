#!/usr/bin/env bash
usage () { echo "Usage: ${BASH_SOURCE[0]} device_abs_route fs_label"; }

dev_route="$1" # device absolute route eg: /dev_route/sdx
fs_label="$2" # fs_label for the fs

compress_alg="zstd:6"
mountpoint="/mnt/$fs_label"
pve_storage_path="$mountpoint"/@"$fs_label"-pve
# for PVE < 8, NO "@". Ref: https://forum.proxmox.com/threads/setting-up-backup-location-error-with-in-file-path.125856/


#######################################################################
#  by panchuz                                                         #
#  to crete a btrfs structure for PVE Storage Manager and other stuff #
#######################################################################

# Sanity check
# ref: if command; then command; else command; fi
if ! [ $# -eq 2 ]; then { usage; return 1; }; fi

# carga de biblioteca de funciones generales
#source <(wget --quiet -O - https://raw.githubusercontent.com/panchuz/linux_setup/main/general.func.sh)

mkfs.btrfs -L "$fs_label" "$dev_route" || return 1

mkdir "$mountpoint"

cat <<-EOF >>/etc/fstab
	# by panchuz for $fs_label, partitionless btrfs w/PVE Managed Storage
	# subvolumes & options: https://docs.google.com/spreadsheets/d/1wo6dBPTnL5k3w7smA_RA9fiwd9cunhLJKzpaU-NM8iw/edit#gid=0
	LABEL=$fs_label $mountpoint btrfs noatime,lazytime,autodefrag,compress=$compress_alg,commit=120 0 0
EOF

mount "$mountpoint"

# Subvolume creation
btrfs subv create "$pve_storage_path"
btrfs subv create "$mountpoint"/@playables
btrfs subv create "$mountpoint"/@downloads
btrfs subv create "$mountpoint"/@logs
btrfs subv create "$mountpoint"/@temp

pvesm add btrfs "$fs_label" \
	--path "$pve_storage_path" \
 	--content iso,backup,images,vztmpl,rootdir,snippets \
  	--format subvol \
	--is_mountpoint "$mountpoint" \
	|| return 1
 
# PVE Storage compression tuning
# Note "compression no" clears both "+c" and "+m" extended attributesm.
# For btrfs to NOT try to compress, we need to set "+m" using chattr
btrfs prop set "$pve_storage_path"/images compression zstd
btrfs prop set "$pve_storage_path"/template compression no
    btrfs prop set "$pve_storage_path"/template/iso compression no
    btrfs prop set "$pve_storage_path"/template/cache compression no
chattr -R +m "$pve_storage_path"/template
btrfs prop set "$pve_storage_path"/dump compression no
chattr -R +m "$pve_storage_path"/dump
btrfs prop set "$pve_storage_path"/snippets compression zstd


# No compressión
btrfs prop set "$mountpoint"/@playables compression no
chattr -R +m "$mountpoint"/@playables
btrfs prop set "$mountpoint"/@downloads compression no
chattr -R +m "$mountpoint"/@downloads

# No Data COW (meaning NO compression and NO datasum)
chattr +C "$mountpoint"/@logs
chattr +C "$mountpoint"/@temp
