#!/usr/bin/env bash
usage () { echo "Usage: ${BASH_SOURCE[0]}\nNo arguments supported"; }

#######################################################################
#  by panchuz                                                         #
#  Proxmox post install script for single node (no cluster)           #
#  on BTRFS root filesystem                                           #
#######################################################################

# Sanity check
# ref: if command; then command; else command; fi
if ! [ $# -eq 0 ]; then { usage; return 1; }; fi


# edit /etc/fstab for btrfs noatime,lazytime,autodefrag,compress=zstd:?,commit=120 0 0
cp /etc/fstab /etc/fstab.INSTALLED

# Get the root filesystem device path
rootfs_dev_path=$(df / | tail -1 | awk '{print $1}')

# Get the device name without partition number
device_name=$(lsblk -no PKNAME $rootfs_dev_path)

# Check if the device is rotational
rotational_file="/sys/block/$device_name/queue/rotational"

if [[ -f $rotational_file ]]; then
    is_rotational=$(cat $rotational_file)
    if [[ $is_rotational -eq 1 ]]; then
        echo "The root file system is on a rotational device => compress=zstd:6"
		sed -i 's/btrfs defaults 0 1/btrfs noatime,lazytime,autodefrag,compress=zstd:6,commit=120 0 0/g' /etc/fstab
    else
        echo "The root file system is not on a rotational device => compress=zstd:1"
		sed -i 's/btrfs defaults 0 1/btrfs noatime,lazytime,autodefrag,compress=zstd:1,commit=120 0 0/g' /etc/fstab
    fi
else
    echo "Could not determine if the device is rotational => compress=zstd:1"
	sed -i 's/btrfs defaults 0 1/btrfs noatime,lazytime,autodefrag,compress=zstd:1,commit=120 0 0/g' /etc/fstab
fi

# swap file creation
# https://wiki.archlinux.org/title/btrfs#Swap_file
btrfs subvolume create /@swap
#mount -o subvol=/@swap "$rootfs_dev_path" /swap
btrfs filesystem mkswapfile --size 4g --uuid clear /@swap/swapfile
swapon /@swap/swapfile
echo "/@swap/swapfile none swap defaults 0 0" >> /etc/fstab


# Proxmox VE Post Install by tteck
# --- DON´T UPDATE UPGRADE PLZ ---
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/post-pve-install.sh)"


# disable/delete ceph and pve-enterprise repos
rm /etc/apt/sources.list.d/ceph.list
rm /etc/apt/sources.list.d/pve-enterprise.list

# Load general functions 
source <(wget --quiet -O - https://raw.githubusercontent.com/panchuz/linux_setup/main/general.func.sh)

# Actualización desatendida "confdef/confold"
# mailx es pedido en /etc/apt/apt.conf.d/50unattended-upgrades para notificar por mail
# apt-listchanges es indicado en https://wiki.debian.org/UnattendedUpgrades#Automatic_call_via_.2Fetc.2Fapt.2Fapt.conf.d.2F20auto-upgrades
apt_dist_upgrade_install postfix-pcre unattended-upgrades sudo curl \ 
	btrfs-compsize iotop htop tmux mc
	#  folder2ram log2ram ???? maybe next time...

# Update the list of available lxc templates
pveam update


 
# -------------------

###### Reduce SSD wearout section start ######

# proxmox logs a lot of stuff. you can reduce ssd wear by using 'folder2ram' to host various directories on tmpfs file systems.
# /var/log
# /var/lib/pve-cluster
# /var/lib/pve-manager
# /var/lib/rrdcached
# I prefer folder2ram over log2ram as folder2ram gives you the granularity to specify a size for each filesystem, rather than one size that 'fits all'.
# you should make it a point to edit /etc/logrotate.conf and /etc/logrotate.d/*.conf to reduce the amount/size of log files.

# on rrdcached
# https://forum.proxmox.com/threads/reducing-rrdcached-writes.64473/

# NO systemctl disable pve-cluster.service !!!!!
# here´s an alternative
# https://github.com/isasmendiagus/pmxcfs-ram

###### Reduce SSD wearout section end ######



# btrfs HDD for pve-storage, logs, playables, etc
# logs AWAY btrfs ???????????
# https://forum.proxmox.com/threads/change-var-log-pveproxy-var-log-pve-locations.110265/




# New users unproot (uid:100000) panchuz (uid:101000) ????
# enable panchuz ssh access with ed25519 key
# disable ssh root access





## LetsEncrypt certificates using ACME
## 2FA ???

# Enable messaging system:
# Gotify? authenticated smtp? traditional?

## /root/.vars/*.vars.sh files

## enable IOMMU ???
## HDD pass-through ???
## automatic backups ???

## Setup Proxmox server monitoring with InfluxDB & Grafana ????
