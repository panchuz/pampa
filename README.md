
## PVE post install tuning
### execute within the Proxmox Shell to source
```
export GITHUB_BRANCH=test && \
    bash -c "$(wget -qLO - https://github.com/panchuz/pampa/raw/main/pve_btrfs_post_install.sh)"
```

## Create a BTRFS storage
### execute within the Proxmox Shell to source
```
export GITHUB_BRANCH=test && \
    bash -c "$(wget -qLO - https://github.com/panchuz/pampa/raw/main/pve_btrfs_storage_create.sh)"
```
#### https://docs.google.com/spreadsheets/d/1wo6dBPTnL5k3w7smA_RA9fiwd9cunhLJKzpaU-NM8iw/edit#gid=1188475892
