#!/bin/bash

# edit /etc/fstab for btrfs
# noatime,lazytime,compress=zstd:1,commit=120

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

apt install btrfs-compsize
# htop tmux mc ?

# New users unproot (uid:100000) panchuz (uid:101000) ????


## enable IOMMU ?
## HDD pass-through

## Setup Proxmox server monitoring with InfluxDB & Grafana ????
