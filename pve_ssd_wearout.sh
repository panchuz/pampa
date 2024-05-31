
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


