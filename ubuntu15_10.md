# Ubuntu & Docker w/ devicemapper 15.10 install notes

IF starting with **Ubuntu 14.04 (Trusty Tahr)**, start here and continue through the end:

```shell
# upgrade to Ubuntu 15.10 (Wily Werewolf)
$ apt-get update && apt-get -y install update-manager-core
$ vi /etc/update-manager/release-upgrades
Prompt=normal

$ do-release-upgrade (may have to do this more than once to get to 15.10)
$ lsb_release -a
Distributor ID:	Ubuntu
Description:	Ubuntu 15.10
Release:	15.10
Codename:	wily
```

IF starting with **Ubuntu 15.10 (Wily Werewolf)**, start here:

```shell
$ apt-get update && apt-get -y install libdevmapper* libudev* udev aufs-tools libdevmapper-event* libudev-dev libdevmapper-dev golang make gcc btrfs-tools libsqlite3-dev overlayroot debootstrap linux-image-generic linux-image-extra-$(uname -r) curl apt-transport-https ca-certificates && apt-get upgrade
$ apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
$ dpkg -l | grep -E '(mapper|udev)'
ii  libdevmapper-dev:amd64              2:1.02.99-1ubuntu1              amd64        Linux Kernel Device Mapper header files
ii  libdevmapper-event1.02.1:amd64      2:1.02.99-1ubuntu1              amd64        Linux Kernel Device Mapper event support library
ii  libdevmapper1.02.1:amd64            2:1.02.99-1ubuntu1              amd64        Linux Kernel Device Mapper userspace library
ii  libudev-dev:amd64                   225-1ubuntu9                    amd64        libudev development files
ii  libudev1:amd64                      225-1ubuntu9                    amd64        libudev shared library
ii  udev                                225-1ubuntu9                    amd64        /dev/ and hotplug management daemon

# TESTED WITH DOCKER-ENGINE (v1.10.3 or later) SO ITS WHAT I RECOMMEND FOR NOW
$ vi /etc/apt/sources.list.d/docker.list
deb https://apt.dockerproject.org/repo ubuntu-wily main

$ apt-get update && apt-get purge lxc-docker
$ apt-cache policy docker-engine && apt-get -y install docker-engine
$ systemctl enable docker
$ vi /lib/systemd/system/docker.service
[Service]
Type=notify
EnvironmentFile=/etc/default/docker
ExecStart=/usr/bin/docker daemon -H fd:// $DOCKER_OPTS
```

_Choose [DEFAULT](#default) or [RECOMMENDED](#recommd) (segmented data volume) path for devicemapper setup._

###### DEFAULT<a name="default"></a> ######
```shell
$ vi /etc/default/docker
DOCKER_OPTS="-s devicemapper --storage-opt dm.basesize=30G"

$ systemctl daemon-reload
```

_**OR**_

###### RECOMMENDED<a name="recommd"></a> ######
FIRST, add 50GB or more of raw disk to your server
```shell
# AFTER adding 50GB or more of raw disk to your server
# install lvm2 and get started
$ apt-get -y install lvm2

# find addtl disk ... make note of disk path
$ fdisk -l

# use addtl disk to create dedicated volumes ("/dev/sdd" could be different on your server)
$ pvcreate /dev/sdd
$ vgcreate docker_dmapper /dev/sdd
$ lvcreate --wipesignatures y -n data docker_dmapper -l 95%VG
$ lvcreate --wipesignatures y -n metadata docker_dmapper -l 5%VG

$ vi /etc/default/docker
DOCKER_OPTS="-s devicemapper --storage-opt dm.datadev=/dev/docker_dmapper/data --storage-opt dm.metadatadev=/dev/docker_dmapper/metadata --storage-opt dm.basesize=40G"

$ systemctl stop docker
$ rm -rf /var/lib/docker
$ systemctl daemon-reload
```

Finish configuration:
```shell
$ vi /etc/default/grub
GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"

$ update-grub
$ reboot now

$ docker info
Storage Driver: devicemapper
 Udev Sync Supported: true
```