#!/usr/bin/env bash
dev="$1" # device route
label="$2" # label for the fs

mountpoint="/mnt/$label"
compress_alg="zstd:6"

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

btrfs subv create "$mountpoint"{@"$label"-pve @playables @downloads @logs @temp}

btrfs prop set "$mountpoint"@"$label"-pve/images compression zstd
btrfs prop set "$mountpoint"@"$label"-pve/template compression no
### ...iso/ & .../cache ????????????????????????????????????????????????????????
btrfs prop set "$mountpoint"@"$label"-pve/dump compression no
btrfs prop set "$mountpoint"@"$label"-pve/snippets compression zstd
btrfs prop set "$mountpoint"@"$label"-pve/palyable compression no
btrfs prop set "$mountpoint"@"$label"-pve/downloads compression no
chattr +C "$mountpoint"@logs
chattr +C "$mountpoint"@temp
