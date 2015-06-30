# Ubuntu & Docker w/ devicemapper 15.04 install notes

_IF starting with **Ubuntu 14.04 (Trusty Tahr)**, start here and continue through the end:_

```shell
# upgrade to Ubuntu 15.04 (Vivid Vervet)
$ apt-get update && apt-get install update-manager-core
$ vi /etc/update-manager/release-upgrades
Prompt=normal

$ do-release-upgrade (may have to do this more than once to get to 15.04)
```

_IF starting with **Ubuntu 15.04 (Vivid Vervet)**, start here:_

```shell
$ apt-get update && apt-get -y install libdevmapper* libudev* udev aufs-tools libdevmapper-event* libudev-dev libdevmapper-dev golang make gcc btrfs-tools libsqlite3-dev overlayroot debootstrap
$ dpkg -l | grep -E '(mapper|udev)'
ii  libdevmapper-dev:amd64              2:1.02.90-2ubuntu1           amd64        Linux Kernel Device Mapper header files
ii  libdevmapper-event1.02.1:amd64      2:1.02.90-2ubuntu1           amd64        Linux Kernel Device Mapper event support library
ii  libdevmapper1.02.1:amd64            2:1.02.90-2ubuntu1           amd64        Linux Kernel Device Mapper userspace library
ii  libudev-dev:amd64                   219-7ubuntu5                 amd64        libudev development files
ii  libudev1:amd64                      219-7ubuntu5                 amd64        libudev shared library
ii  udev                                219-7ubuntu5                 amd64        /dev/ and hotplug management daemon

# WORKS WITH DOCKER 1.6.2 SO ITS WHAT I RECOMMEND FOR NOW
$ echo deb http://get.docker.com/ubuntu docker main > /etc/apt/sources.list.d/docker.list
$ apt-key adv --keyserver pgp.mit.edu --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
$ apt-get update
$ apt-get install -y lxc-docker-1.6.2
$ vi /etc/default/grub
GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"

$ update-grub
$ reboot now

$ cd ~
$ git clone --branch v1.6.2 https://github.com/docker/docker
$ cd docker
$ DOCKER_BUILDTAGS=btrfs_noversion AUTO_GOPATH=1 ./hack/make.sh dynbinary

$ service docker stop
$ cp -p bundles/1.6.2/dynbinary/dockerinit-1.6.2 /var/lib/docker/init;cp -p bundles/1.6.2/dynbinary/docker-1.6.2 /usr/bin/docker

# next docker version will fix auto startup (systemctl integration) and DOCKER_OPTS ability for 15.04... for now though, we'll run docker manually for this test.
$ docker -d -s devicemapper --storage-opt dm.basesize=30G &

$ docker info
Storage Driver: devicemapper
 Udev Sync Supported: true
```
