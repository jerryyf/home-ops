# NFS Setup

How to setup mounting NFS at boot on a new VM.

Install nfs-common:
```
sudo apt install nfs-common
```

Add this line to /etc/fstab:
```
192.168.1.100:/mnt/store/media    /mnt/nfs/media    nfs    rw,nosuid,noexec,nodev,auto,hard,intr,_netdev    0    0
```

Then reload and mount:
```
sudo systemctl daemon-reload && sudo mount -a
```
