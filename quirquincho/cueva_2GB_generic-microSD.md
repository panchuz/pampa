
#### added cueva to PVE managed storage system
```
pvesm add dir cueva --path /mnt/cueva --content iso,backup,vztmpl
root@quirquincho:~# cat /etc/pve/stora*
dir: local
        disable
        path /var/lib/vz
        content iso,vztmpl,backup

btrfs: local-btrfs
        path /var/lib/pve/local-btrfs
        content rootdir,iso,backup,images,snippets,vztmpl

dir: cueva
        path /mnt/cueva
        content backup,vztmpl,iso
```

### Ref: https://wiki.archlinux.org/title/F2FS
#### root@quirquincho:~# lsattr -R /mnt/cueva
```
------------------N--- /mnt/cueva/cueva_creacion.txt
------------------N--- /mnt/cueva/UUID.txt
-----------I------N--m /mnt/cueva/template

/mnt/cueva/template:
-----------I------N--m /mnt/cueva/template/iso

/mnt/cueva/template/iso:

-----------I------N--m /mnt/cueva/template/cache

/mnt/cueva/template/cache:
---------------------m /mnt/cueva/template/cache/debian-12-standard_12.2-1_amd64.tar.zst


-----------I------N--m /mnt/cueva/dump

/mnt/cueva/dump:
------------------N--m /mnt/cueva/dump/vzdump-lxc-200-2023_04_14-13_55_24.tar.zst.notes
---------------------m /mnt/cueva/dump/vzdump-lxc-200-2023_04_14-13_55_24.tar.zst
------------------N--m /mnt/cueva/dump/vzdump-lxc-200-2023_04_14-13_55_24.tar.zst.protected
------------------N--m /mnt/cueva/dump/vzdump-lxc-200-2023_04_14-13_55_24.log
------------------N--m /mnt/cueva/dump/vzdump-lxc-200-2023_06_14-20_51_14.tar.zst.notes
---------------------m /mnt/cueva/dump/vzdump-lxc-200-2023_06_14-20_51_14.tar.zst
------------------N--m /mnt/cueva/dump/vzdump-lxc-200-2023_06_14-20_51_14.tar.zst.protected
------------------N--m /mnt/cueva/dump/vzdump-lxc-200-2023_06_14-20_51_14.log

-----------I------N--- /mnt/cueva/images

/mnt/cueva/images:
-----------I------N--- /mnt/cueva/images/104

/mnt/cueva/images/104:
---------------------- /mnt/cueva/images/104/vm-104-disk-0.raw


-----------I------N--- /mnt/cueva/private

/mnt/cueva/private:

-----------I------N--- /mnt/cueva/snippets

/mnt/cueva/snippets:
```

### excepciones a la compresión
```
chattr -R +m /mnt/cueva/dump
chattr -R +m /mnt/cueva/template
```

### root@quirquincho:~# cat /etc/fstab
```
# cueva microSD 2GB genérica
# https://wiki.archlinux.org/title/F2FS#Recommended_mount_options
UUID=4ee5f354-3cad-4fdf-8da3-842b457aa64e /mnt/cueva f2fs noatime,lazytime,atgc,gc_merge,compress_algorithm=zstd:6,compress_chksum,compress_extension=log 0 0
```

### root@quirquincho:~# mount |grep cueva
```
/dev/sdb on /mnt/cueva type f2fs (rw,noatime,lazytime,background_gc=on,gc_merge,nodiscard,no_heap,user_xattr,inline_xattr,noacl,inline_data,inline_dentry,flush_merge,barrier,extent_cache,mode=adaptive,active_logs=6,alloc_mode=reuse,checkpoint_merge,fsync_mode=posix,compress_algorithm=zstd:6,compress_log_size=2,compress_extension=log,compress_chksum,compress_mode=fs,atgc,discard_unit=block,memory=normal)
```


### mkfs.f2fs -f -l cueva -O extra_attr,inode_checksum,sb_checksum,compression /dev/mmcblk0
````
user@debian:~$ sudo mkfs.f2fs -f -l cueva -O extra_attr,inode_checksum,sb_checksum,compression /dev/mmcblk0

        F2FS-tools: mkfs.f2fs Ver: 1.14.0 (2020-08-24)

Info: Disable heap-based policy
Info: Debug level = 0
Info: Label = cueva
Info: Trim is enabled
Info: Segments per section = 1
Info: Sections per zone = 1
Info: sector size = 512
Info: total sectors = 3862528 (1886 MB)
Info: zone aligned segment0 blkaddr: 512
Info: format version with
  "Linux version 5.10.0-2-amd64 (debian-kernel@lists.debian.org) (gcc-10 (Debian 10.2.1-6) 10.2.1 20210110, GNU ld (GNU Binutils for Debian) 2.35.1) #1 SMP Debian 5.10.9-1 (2021-01-20)"
Info: [/dev/mmcblk0] Discarding device
Info: This device doesn't support BLKSECDISCARD
Info: Discarded 1886 MB
Info: Overprovision ratio = 4.660%
Info: Overprovision segments = 91 (GC reserved = 50)
Info: format successful

user@debian:~$ sudo fsck.f2fs /dev/mmcblk0
Info: Segments per section = 1
Info: Sections per zone = 1
Info: sector size = 512
Info: total sectors = 3862528 (1886 MB)
Info: MKFS version
  "Linux version 5.10.0-2-amd64 (debian-kernel@lists.debian.org) (gcc-10 (Debian 10.2.1-6) 10.2.1 20210110, GNU ld (GNU Binutils for Debian) 2.35.1) #1 SMP Debian 5.10.9-1 (2021-01-20)"
Info: FSCK version
  from "Linux version 5.10.0-2-amd64 (debian-kernel@lists.debian.org) (gcc-10 (Debian 10.2.1-6) 10.2.1 20210110, GNU ld (GNU Binutils for Debian) 2.35.1) #1 SMP Debian 5.10.9-1 (2021-01-20)"
    to "Linux version 5.10.0-2-amd64 (debian-kernel@lists.debian.org) (gcc-10 (Debian 10.2.1-6) 10.2.1 20210110, GNU ld (GNU Binutils for Debian) 2.35.1) #1 SMP Debian 5.10.9-1 (2021-01-20)"
Info: superblock features = 2828 :  extra_attr inode_checksum sb_checksum compression
Info: superblock encrypt level = 0, salt = 00000000000000000000000000000000
Info: total FS sectors = 3862528 (1886 MB)
Info: CKPT version = 7cce3bf1
Info: Checked valid nat_bits in checkpoint
Info: checkpoint state = 185 :  trimmed nat_bits compacted_summary unmount

[FSCK] Unreachable nat entries                        [Ok..] [0x0]
[FSCK] SIT valid block bitmap checking                [Ok..]
[FSCK] Hard link checking for regular file            [Ok..] [0x0]
[FSCK] valid_block_count matching with CP             [Ok..] [0x2]
[FSCK] valid_node_count matching with CP (de lookup)  [Ok..] [0x1]
[FSCK] valid_node_count matching with CP (nat lookup) [Ok..] [0x1]
[FSCK] valid_inode_count matched with CP              [Ok..] [0x1]
[FSCK] free segment_count matched with CP             [Ok..] [0x39c]
[FSCK] next block offset is free                      [Ok..]
[FSCK] fixing SIT types
[FSCK] other corrupted bugs                           [Ok..]

Done: 0.663221 secs
user@debian:~$ mount /dev/mmcblk0 /mnt
mount: /mnt: must be superuser to use mount.
user@debian:~$ sudo mount /dev/mmcblk0 /mnt
```
user@debian:~$ 
