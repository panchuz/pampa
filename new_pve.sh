#!/bin/bash

# edit /etc/fstab for btrfs noatime,lazytime,autodefrag,compress=zstd:?,commit=120 0 0
cp /etc/fstab /etc/fstab.INSTALLED
sed -i 's/btrfs defaults 0 1/btrfs noatime,lazytime,autodefrag,compress=zstd:6,commit=120 0 0/g' /etc/fstab


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
