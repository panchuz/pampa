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


header_info() {
  clear
  cat <<"EOF"
    ____ _    ________   ____             __     ____           __        ____
   / __ \ |  / / ____/  / __ \____  _____/ /_   /  _/___  _____/ /_____ _/ / /
  / /_/ / | / / __/    / /_/ / __ \/ ___/ __/   / // __ \/ ___/ __/ __ `/ / /
 / ____/| |/ / /___   / ____/ /_/ (__  ) /_   _/ // / / (__  ) /_/ /_/ / / /
/_/     |___/_____/  /_/    \____/____/\__/  /___/_/ /_/____/\__/\__,_/_/_/

for btrfs root filesystem
by panchuz
mostly taken from https://github.com/tteck/Proxmox

EOF
}

RD=$(echo "\033[01;31m")
YW=$(echo "\033[33m")
GN=$(echo "\033[1;92m")
CL=$(echo "\033[m")
BFR="\\r\\033[K"
HOLD="-"
CM="${GN}✓${CL}"
CROSS="${RD}✗${CL}"

set -euo pipefail
shopt -s inherit_errexit nullglob

msg_info() {
  local msg="$1"
  echo -ne " ${HOLD} ${YW}${msg}..."
}

msg_ok() {
  local msg="$1"
  echo -e "${BFR} ${CM} ${GN}${msg}${CL}"
}

msg_error() {
  local msg="$1"
  echo -e "${BFR} ${CROSS} ${RD}${msg}${CL}"
}

start_routines() {
	header_info

	msg_info "Modifing /etc/fstab for root btrfs best performace"
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
			msg_info "root fs is on a rotational device. Setting strong compression."
			sed -i 's/btrfs defaults 0 1/btrfs noatime,lazytime,autodefrag,compress=zstd:6,commit=120 0 0/g' /etc/fstab
		else
			msg_info "root fs is not on a rotational device. Setting light compression."
			sed -i 's/btrfs defaults 0 1/btrfs noatime,lazytime,autodefrag,compress=zstd:1,commit=120 0 0/g' /etc/fstab
		fi
	else
		msg_error "Could not determine if root fs device is rotational. Setting light compression."
		sed -i 's/btrfs defaults 0 1/btrfs noatime,lazytime,autodefrag,compress=zstd:1,commit=120 0 0/g' /etc/fstab
	fi
	systemctl daemon-reload
 	mount --options remount /
	msg_ok "fstab modified for root btrfs best performace"


	msg_info "Creating swap file"
	# https://wiki.archlinux.org/title/btrfs#Swap_file
	btrfs subvolume create /@swap  &>/dev/null
	#mount -o subvol=/@swap "$rootfs_dev_path" /swap
	btrfs filesystem mkswapfile --size 4g --uuid clear /@swap/swapfile  &>/dev/null
	swapon /@swap/swapfile
	echo "/@swap/swapfile none swap defaults 0 0" >> /etc/fstab
	msg_ok "Swap file created"


	##### Begining of tteck section #####
	# shamelesly copied form https://github.com/tteck/Proxmox/blob/main/misc/post-pve-install.sh
	# just eliminated the choices... and removed ceph and pve-enterprise repos

	msg_info "Correcting Proxmox VE Sources"
	cat <<-EOF >/etc/apt/sources.list
		deb http://deb.debian.org/debian bookworm main contrib
		deb http://deb.debian.org/debian bookworm-updates main contrib
		deb http://security.debian.org/debian-security bookworm-security main contrib
	EOF
	echo 'APT::Get::Update::SourceListWarnings::NonFreeFirmware "false";' \
		>/etc/apt/apt.conf.d/no-bookworm-firmware.conf

	# disable/delete ceph and pve-enterprise repos
	rm /etc/apt/sources.list.d/ceph.list
	rm /etc/apt/sources.list.d/pve-enterprise.list

    cat <<-EOF >/etc/apt/sources.list.d/pve-install-repo.list
		deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription
	EOF

	cat <<-EOF >/etc/apt/sources.list.d/pvetest-for-beta.list
		# deb http://download.proxmox.com/debian/pve bookworm pvetest
	EOF
	msg_ok "Corrected Proxmox VE Sources"

	msg_info "Disabling subscription nag"
    echo "DPkg::Post-Invoke { \"dpkg -V proxmox-widget-toolkit | grep -q '/proxmoxlib\.js$'; if [ \$? -eq 1 ]; then { echo 'Removing subscription nag from UI...'; sed -i '/.*data\.status.*{/{s/\!//;s/active/NoMoreNagging/}' /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js; }; fi\"; };" >/etc/apt/apt.conf.d/no-nag-script
      apt --reinstall install proxmox-widget-toolkit &>/dev/null
    msg_ok "Disabled subscription nag (Delete browser cache)"

	msg_info "Disabling high availability"
    systemctl disable -q --now pve-ha-lrm
    systemctl disable -q --now pve-ha-crm
    systemctl disable -q --now corosync
    msg_ok "Disabled high availability"

	##### End of tteck section #####
	

	# Load general functions 
	source <(wget --quiet -O - http://github.com/panchuz/setup_linux/raw/$GITHUB_BRANCH/general.func.sh)

	# Actualización desatendida "confdef/confold"
	# mailx es pedido en /etc/apt/apt.conf.d/50unattended-upgrades para notificar por mail
	# apt-listchanges es indicado en https://wiki.debian.org/UnattendedUpgrades#Automatic_call_via_.2Fetc.2Fapt.2Fapt.conf.d.2F20auto-upgrades
	apt_dist_upgrade_install postfix-pcre unattended-upgrades sudo curl btrfs-compsize iotop htop tmux mc
		#  folder2ram log2ram ???? maybe next time...

	# Update the list of available lxc templates
	pveam update

}



header_info

if ! pveversion | grep -Eq "pve-manager/8.[0-2]"; then
  msg_error "This version of Proxmox Virtual Environment is not supported"
  echo -e "Requires Proxmox Virtual Environment Version 8.0 or later."
  echo -e "Exiting..."
  sleep 2
  exit
fi

start_routines

