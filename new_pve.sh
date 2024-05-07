#!/bin/bash

# edit /etc/fstab for btrfs
# noatime,lazytime,compress=zstd:1,commit=120

### Reduce SSD wearout section ###
# Most writes should be logs, rrdcached metrics and the cluster service with its pmxcfs DB

# https://www.reddit.com/r/Proxmox/comments/ncg2xo/minimizing_ssd_wear_through_pve_configuration/
# https://www.reddit.com/r/Proxmox/comments/129dxw7/proxmox_high_disk_writes/
systemctl disable --now pve-ha-crm.service
systemctl disable --now pve-ha-lrm.service
systemctl disable --now pvesr.timer
systemctl disable --now corosync.service

#systemctl stop pve-cluster.service ?????!!!!!
# https://github.com/isasmendiagus/pmxcfs-ram

# proxmox logs a lot of stuff. you can reduce ssd wear by using 'folder2ram' to host various directories on tmpfs file systems.
# /var/log
# /var/lib/pve-cluster
# /var/lib/pve-manager
# /var/lib/rrdcached
# I prefer folder2ram over log2ram as folder2ram gives you the granularity to specify a size for each filesystem, rather than one size that 'fits all'.
# you should make it a point to edit /etc/logrotate.conf and /etc/logrotate.d/*.conf to reduce the amount/size of log files.

# on rrdcached
# https://forum.proxmox.com/threads/reducing-rrdcached-writes.64473/

### Reduce SSD wearout section end ###


# btrfs HDD for pve-storage, logs, playables, etc
# logs AWAY btrfs ???????????
# https://forum.proxmox.com/threads/change-var-log-pveproxy-var-log-pve-locations.110265/

# para evitar “You do not have a valid subscription for this server….”
# https://dannyda.com/2020/05/17/how-to-remove-you-do-not-have-a-valid-subscription-for-this-server-from-proxmox-virtual-environment-6-1-2-proxmox-ve-6-1-2-pve-6-1-2/
sed -i.backup -z "s/res === null || res === undefined || \!res || res\n\t\t\t.data.status.toLowerCase() \!== 'active'/false/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js \
	&& systemctl restart pveproxy.service


# no subscription updates repo
# disable/delete Ceph storage repo
# apt update && apt upgrade


## LetsEncrypt certificates using ACME

## 2FA ???

apt install btrfs-compsize iotop htop tmux
# mc folder2ram log2ram ????

# New users unproot (uid:100000) panchuz (uid:101000) ????

## /root/.vars/*.vars.sh files

## enable IOMMU ???
## HDD pass-through ???
## automatic backups ???

## Setup Proxmox server monitoring with InfluxDB & Grafana ????
