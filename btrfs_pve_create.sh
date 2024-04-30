#!/usr/bin/env bash
dev="$1" # device route
label="$2" # label for the fs

compress_alg="zstd:6"
mountpoint="/mnt/$label"
pve_storage_path="$pve_storage_path"

#######################################################################
#  bt panchuz                                                         #
#  to crete a btrfs structure for PVE Storage Manager and stuff       #
#######################################################################

# verificación de la cantidad de argumentos
if [ $# -ne 2 ]; then
	echo "Uso: ${BASH_SOURCE[0]} device_abs_route label"
	return 1
fi

# carga de biblioteca de funciones generales
#source <(wget --quiet -O - https://raw.githubusercontent.com/panchuz/linux_setup/main/general.func.sh)

mkfs.btrfs -L "$label" "$dev"

mkdir "$mountpoint"

cat <<-EOF >>/etc/fstab
    # by panchuz for "$label", partitionless btrfs w/PVE Managed Storage
    # subvolumes & options: https://docs.google.com/spreadsheets/d/1wo6dBPTnL5k3w7smA_RA9fiwd9cunhLJKzpaU-NM8iw/edit#gid=0
    LABEL="$label" "$mountpoint" btrfs noatime,lazytime,noacl,autodefrag,compress="$compress_alg",commit=120 0 0
EOF

mount "$mountpoint"

# Subvolume creation
btrfs subv create "$mountpoint"/@"$label"-pve
btrfs subv create "$mountpoint"/@playables
btrfs subv create "$mountpoint"/@downloads
btrfs subv create "$mountpoint"/@logs
btrfs subv create "$mountpoint"/@temp

# pvesm add dir <STORAGE_ID> --path <PATH>
#btrfs: data2
#        path /mnt/data2/pve-storage
#        content rootdir,images
#        is_mountpoint /mnt/data2
pvesm add btrfs "$label" --path "$pve_storage_path" --is_mountpoint "$mountpoint"

# PVE Storage compression discriminated
btrfs prop set "$pve_storage_path"/images compression zstd
btrfs prop set "$pve_storage_path"/template compression no
#btrfs prop set "$pve_storage_path"/template/iso compression no
#btrfs prop set "$pve_storage_path"/template/cache compression no
btrfs prop set "$pve_storage_path"/dump compression no
btrfs prop set "$pve_storage_path"/snippets compression zstd

# No compressión
btrfs prop set "$mountpoint"/@palyable compression no
btrfs prop set "$mountpoint"/@downloads compression no

# No Data COW (meanning NO compression and NO datasum)
chattr +C "$mountpoint"/@logs
chattr +C "$mountpoint"/@temp
