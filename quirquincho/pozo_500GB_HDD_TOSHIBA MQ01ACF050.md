
### Creación y propiedades extendidas
Ref:
https://wiki.archlinux.org/title/Btrfs,
https://btrfs.readthedocs.io/en/latest/btrfs-property.html

```
btrfs subvolume create /mnt/pozo/{@pozo-discos @pozo-baul @playables @downloads @temp @logs}

root@quirquincho:~# btrfs property set /mnt/pozo/@pozo-discos compression zstd
root@quirquincho:~# btrfs prop get /mnt/pozo/@pozo-discos
ro=false
compression=zstd
root@quirquincho:~# btrfs prop get /mnt/pozo/@pozo-baul
ro=false

root@quirquincho:~# chattr +C /mnt/pozo/@temp
root@quirquincho:~# chattr +C /mnt/pozo/@logs
root@quirquincho:~# lsattr -R /mnt/pozo
--------c------------- /mnt/pozo/@pozo-discos

/mnt/pozo/@pozo-discos:

---------------------- /mnt/pozo/@pozo-baul

/mnt/pozo/@pozo-baul:

---------------------- /mnt/pozo/@downloads

/mnt/pozo/@downloads:

---------------------- /mnt/pozo/@playables

/mnt/pozo/@playables:

---------------C------ /mnt/pozo/@temp

/mnt/pozo/@temp:

---------------C------ /mnt/pozo/@logs

/mnt/pozo/@logs:

root@quirquincho:~# lsattr -Rl /mnt/pozo
/mnt/pozo/@pozo-discos       Compression_Requested

/mnt/pozo/@pozo-discos:

/mnt/pozo/@pozo-baul         ---

/mnt/pozo/@pozo-baul:

/mnt/pozo/@downloads         ---

/mnt/pozo/@downloads:

/mnt/pozo/@playables         ---

/mnt/pozo/@playables:

/mnt/pozo/@temp              No_COW

/mnt/pozo/@temp:

/mnt/pozo/@logs              No_COW

/mnt/pozo/@logs:

root@quirquincho:~#
```

### root@quirquincho:~# mount |grep pozo
```
/dev/sda on /mnt/pozo type btrfs (rw,noatime,lazytime,noacl,space_cache=v2,autodefrag,commit=120,subvolid=5,subvol=/)
```

### en /etc/fstab
```
# agregado por panchuz para "pozo" partitionless 500GB HDD TOSHIBA
# subvolumes & options: https://docs.google.com/spreadsheets/d/1wo6dBPTnL5k3w7smA_RA9fiwd9cunhLJKzpaU-NM8iw/edit#gid=0
LABEL=pozo /mnt/pozo btrfs noatime,lazytime,noacl,autodefrag,commit=120 0 0
```

### creación
```
mkfs.btrfs -L pozo /dev/sda
```



### subvolumes with different mount options
### from obsolete: https://archive.kernel.org/oldwiki/btrfs.wiki.kernel.org/index.php/FAQ.html#Can_I_mount_subvolumes_with_different_mount_options.3F
### https://btrfs.readthedocs.io/en/latest/btrfs-man5.html](https://btrfs.readthedocs.io/en/latest/Subvolumes.html#mount-options

```
Can I mount subvolumes with different mount options?
The generic mount options can be different for each subvolume, see the list below. Btrfs-specific mount options cannot be specified per-subvolume, but this will be possible in the future (a work in progress).

Generic mount options: nodev, nosuid, ro, rw, and probably more. See section FILESYSTEM INDEPENDENT MOUNT OPTIONS of man page mount(8).

Btrfs-specific mount options:
Yes for btrfs-specific options:  subvol or subvolid
Planned:  compress/compress-force, autodefrag, inode_cache, ...
No:  the options affecting the whole filesystem like space_cache, discard, ssd, ...
```

### smartctl con Read errors
#### después se usó badblocks para corregir
```
root@quirquincho:~# smartctl -a /dev/sda
smartctl 7.2 2020-12-30 r5155 [x86_64-linux-6.2.16-4-bpo11-pve] (local build)
Copyright (C) 2002-20, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF INFORMATION SECTION ===
Device Model:     TOSHIBA MQ01ACF050
Serial Number:    35CEC4JQT
LU WWN Device Id: 5 000039 6239848e5
Firmware Version: AV001U
User Capacity:    500,107,862,016 bytes [500 GB]
Sector Sizes:     512 bytes logical, 4096 bytes physical
Rotation Rate:    7200 rpm
Form Factor:      2.5 inches
Device is:        Not in smartctl database [for details use: -P showall]
ATA Version is:   ATA8-ACS (minor revision not indicated)
SATA Version is:  SATA 3.0, 3.0 Gb/s (current: 3.0 Gb/s)
Local Time is:    Sun Apr 21 15:11:01 2024 -03
SMART support is: Available - device has SMART capability.
SMART support is: Enabled

=== START OF READ SMART DATA SECTION ===
SMART overall-health self-assessment test result: PASSED

General SMART Values:
Offline data collection status:  (0x00) Offline data collection activity
                                        was never started.
                                        Auto Offline Data Collection: Disabled.
Self-test execution status:      ( 112) The previous self-test completed having
                                        the read element of the test failed.
Total time to complete Offline 
data collection:                (  120) seconds.
Offline data collection
capabilities:                    (0x5b) SMART execute Offline immediate.
                                        Auto Offline data collection on/off support.
                                        Suspend Offline collection upon new
                                        command.
                                        Offline surface scan supported.
                                        Self-test supported.
                                        No Conveyance Self-test supported.
                                        Selective Self-test supported.
SMART capabilities:            (0x0003) Saves SMART data before entering
                                        power-saving mode.
                                        Supports SMART auto save timer.
Error logging capability:        (0x01) Error logging supported.
                                        General Purpose Logging supported.
Short self-test routine 
recommended polling time:        (   2) minutes.
Extended self-test routine
recommended polling time:        ( 103) minutes.
SCT capabilities:              (0x003d) SCT Status supported.
                                        SCT Error Recovery Control supported.
                                        SCT Feature Control supported.
                                        SCT Data Table supported.

SMART Attributes Data Structure revision number: 16
Vendor Specific SMART Attributes with Thresholds:
ID# ATTRIBUTE_NAME          FLAG     VALUE WORST THRESH TYPE      UPDATED  WHEN_FAILED RAW_VALUE
  1 Raw_Read_Error_Rate     0x000b   100   100   050    Pre-fail  Always       -       0
  2 Throughput_Performance  0x0005   100   100   050    Pre-fail  Offline      -       0
  3 Spin_Up_Time            0x0027   100   100   001    Pre-fail  Always       -       2794
  4 Start_Stop_Count        0x0032   100   100   000    Old_age   Always       -       1479
  5 Reallocated_Sector_Ct   0x0033   100   100   050    Pre-fail  Always       -       120
  7 Seek_Error_Rate         0x000b   100   100   050    Pre-fail  Always       -       0
  8 Seek_Time_Performance   0x0005   100   100   050    Pre-fail  Offline      -       0
  9 Power_On_Hours          0x0032   069   069   000    Old_age   Always       -       12669
 10 Spin_Retry_Count        0x0033   129   100   030    Pre-fail  Always       -       0
 12 Power_Cycle_Count       0x0032   100   100   000    Old_age   Always       -       1474
191 G-Sense_Error_Rate      0x0032   100   100   000    Old_age   Always       -       21
192 Power-Off_Retract_Count 0x0032   100   100   000    Old_age   Always       -       77
193 Load_Cycle_Count        0x0032   075   075   000    Old_age   Always       -       256398
194 Temperature_Celsius     0x0022   100   100   000    Old_age   Always       -       44 (Min/Max 11/54)
196 Reallocated_Event_Count 0x0032   100   100   000    Old_age   Always       -       11
197 Current_Pending_Sector  0x0032   100   100   000    Old_age   Always       -       216
198 Offline_Uncorrectable   0x0030   100   100   000    Old_age   Offline      -       28
199 UDMA_CRC_Error_Count    0x0032   200   200   000    Old_age   Always       -       1
220 Disk_Shift              0x0002   100   100   000    Old_age   Always       -       0
222 Loaded_Hours            0x0032   074   074   000    Old_age   Always       -       10460
223 Load_Retry_Count        0x0032   100   100   000    Old_age   Always       -       0
224 Load_Friction           0x0022   100   100   000    Old_age   Always       -       0
226 Load-in_Time            0x0026   100   100   000    Old_age   Always       -       256
240 Head_Flying_Hours       0x0001   100   100   001    Pre-fail  Offline      -       0

SMART Error Log Version: 1
ATA Error Count: 7698 (device log contains only the most recent five errors)
        CR = Command Register [HEX]
        FR = Features Register [HEX]
        SC = Sector Count Register [HEX]
        SN = Sector Number Register [HEX]
        CL = Cylinder Low Register [HEX]
        CH = Cylinder High Register [HEX]
        DH = Device/Head Register [HEX]
        DC = Device Command Register [HEX]
        ER = Error register [HEX]
        ST = Status register [HEX]
Powered_Up_Time is measured from power on, and printed as
DDd+hh:mm:SS.sss where DD=days, hh=hours, mm=minutes,
SS=sec, and sss=millisec. It "wraps" after 49.710 days.

Error 7698 occurred at disk power-on lifetime: 12666 hours (527 days + 18 hours)
  When the command that caused the error occurred, the device was active or idle.

  After command completion occurred, registers were:
  ER ST SC SN CL CH DH
  -- -- -- -- -- -- --
  40 41 b0 d0 28 21 40  Error: UNC at LBA = 0x002128d0 = 2173136

  Commands leading to the command that caused the error were:
  CR FR SC SN CL CH DH DC   Powered_Up_Time  Command/Feature_Name
  -- -- -- -- -- -- -- --  ----------------  --------------------
  60 08 b0 d0 28 21 40 00      16:56:52.465  READ FPDMA QUEUED
  ef 10 02 00 00 00 a0 00      16:56:52.461  SET FEATURES [Enable SATA feature]
  27 00 00 00 00 00 e0 00      16:56:52.461  READ NATIVE MAX ADDRESS EXT [OBS-ACS-3]
  ec 00 00 00 00 00 a0 00      16:56:52.460  IDENTIFY DEVICE
  ef 03 45 00 00 00 a0 00      16:56:52.460  SET FEATURES [Set transfer mode]

Error 7697 occurred at disk power-on lifetime: 12666 hours (527 days + 18 hours)
  When the command that caused the error occurred, the device was active or idle.

  After command completion occurred, registers were:
  ER ST SC SN CL CH DH
  -- -- -- -- -- -- --
  40 41 e0 d0 28 21 40  Error: UNC at LBA = 0x002128d0 = 2173136

  Commands leading to the command that caused the error were:
  CR FR SC SN CL CH DH DC   Powered_Up_Time  Command/Feature_Name
  -- -- -- -- -- -- -- --  ----------------  --------------------
  60 08 e0 d0 28 21 40 00      16:56:49.809  READ FPDMA QUEUED
  ef 10 02 00 00 00 a0 00      16:56:49.805  SET FEATURES [Enable SATA feature]
  27 00 00 00 00 00 e0 00      16:56:49.805  READ NATIVE MAX ADDRESS EXT [OBS-ACS-3]
  ec 00 00 00 00 00 a0 00      16:56:49.804  IDENTIFY DEVICE
  ef 03 45 00 00 00 a0 00      16:56:49.804  SET FEATURES [Set transfer mode]

Error 7696 occurred at disk power-on lifetime: 12666 hours (527 days + 18 hours)
  When the command that caused the error occurred, the device was active or idle.

  After command completion occurred, registers were:
  ER ST SC SN CL CH DH
  -- -- -- -- -- -- --
  40 41 f8 d0 28 21 40  Error: UNC at LBA = 0x002128d0 = 2173136

  Commands leading to the command that caused the error were:
  CR FR SC SN CL CH DH DC   Powered_Up_Time  Command/Feature_Name
  -- -- -- -- -- -- -- --  ----------------  --------------------
  60 08 f8 d0 28 21 40 00      16:56:47.150  READ FPDMA QUEUED
  ef 10 02 00 00 00 a0 00      16:56:47.146  SET FEATURES [Enable SATA feature]
  27 00 00 00 00 00 e0 00      16:56:47.145  READ NATIVE MAX ADDRESS EXT [OBS-ACS-3]
  ec 00 00 00 00 00 a0 00      16:56:47.145  IDENTIFY DEVICE
  ef 03 45 00 00 00 a0 00      16:56:47.144  SET FEATURES [Set transfer mode]

Error 7695 occurred at disk power-on lifetime: 12666 hours (527 days + 18 hours)
  When the command that caused the error occurred, the device was active or idle.

  After command completion occurred, registers were:
  ER ST SC SN CL CH DH
  -- -- -- -- -- -- --
  40 41 b0 d0 28 21 40  Error: UNC at LBA = 0x002128d0 = 2173136

  Commands leading to the command that caused the error were:
  CR FR SC SN CL CH DH DC   Powered_Up_Time  Command/Feature_Name
  -- -- -- -- -- -- -- --  ----------------  --------------------
  60 08 b0 d0 28 21 40 00      16:56:44.204  READ FPDMA QUEUED
  ef 10 02 00 00 00 a0 00      16:56:44.202  SET FEATURES [Enable SATA feature]
  27 00 00 00 00 00 e0 00      16:56:44.201  READ NATIVE MAX ADDRESS EXT [OBS-ACS-3]
  ec 00 00 00 00 00 a0 00      16:56:44.200  IDENTIFY DEVICE
  ef 03 45 00 00 00 a0 00      16:56:44.200  SET FEATURES [Set transfer mode]

Error 7694 occurred at disk power-on lifetime: 12666 hours (527 days + 18 hours)
  When the command that caused the error occurred, the device was active or idle.

  After command completion occurred, registers were:
  ER ST SC SN CL CH DH
  -- -- -- -- -- -- --
  40 41 00 d0 28 21 40  Error: UNC at LBA = 0x002128d0 = 2173136

  Commands leading to the command that caused the error were:
  CR FR SC SN CL CH DH DC   Powered_Up_Time  Command/Feature_Name
  -- -- -- -- -- -- -- --  ----------------  --------------------
  60 08 00 d0 28 21 40 00      16:56:41.270  READ FPDMA QUEUED
  ef 10 02 00 00 00 a0 00      16:56:41.266  SET FEATURES [Enable SATA feature]
  27 00 00 00 00 00 e0 00      16:56:41.265  READ NATIVE MAX ADDRESS EXT [OBS-ACS-3]
  ec 00 00 00 00 00 a0 00      16:56:41.264  IDENTIFY DEVICE
  ef 03 45 00 00 00 a0 00      16:56:41.264  SET FEATURES [Set transfer mode]

SMART Self-test log structure revision number 1
Num  Test_Description    Status                  Remaining  LifeTime(hours)  LBA_of_first_error
# 1  Short offline       Completed: read failure       00%     12666         75864
# 2  Extended offline    Completed: read failure       00%     12651         75864
# 3  Short offline       Interrupted (host reset)      30%         2         -
# 4  Short offline       Completed without error       00%         1         -
# 5  Short offline       Completed without error       00%         0         -

SMART Selective self-test log data structure revision number 1
 SPAN  MIN_LBA  MAX_LBA  CURRENT_TEST_STATUS
    1        0        0  Not_testing
    2        0        0  Not_testing
    3        0        0  Not_testing
    4        0        0  Not_testing
    5        0        0  Not_testing
Selective self-test flags (0x0):
  After scanning selected spans, do NOT read-scan remainder of disk.
If Selective self-test is pending on power-up, resume after 0 minute delay.

root@quirquincho:~# 
```
