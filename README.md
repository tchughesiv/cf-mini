# CF Mini
Docker image running Cloud Foundry stack - listens on ports 80/443/4443

 - Ubuntu Trusty 14.04
 - Cloud Foundry v237
 - Buildpacks installed:
	- ruby-buildpack
	- nodejs-buildpack
	- java-offline-buildpack
	- binary-buildpack
	- go-buildpack
	- staticfile-buildpack

Cloud Foundry aims to simplify code deployments... once you have a working PaaS stack anyway. Accomplishing this initial setup/install task of the stack itself, however, can be cumbersome.

CF Mini makes it a 2-step process... Pull & Run with Docker.

# requirements:

A Docker server using "devicemapper w/ udev sync enabled" & at least 30gb disk is highly recommended. I intend to do further testing with the btrfs & overlay storage options soon. One's working Docker Server environment must have the following two critical things configured or performance will suffer.

*[Installation instructions for my tested Ubuntu 15.10 server build are here](https://github.com/tchughesiv/cf-mini/blob/master/ubuntu15_10.md).*

1.) Server process should look similar to one of these:
```sh
# devicemapper default setup
$ ps -ef |grep -i docker
docker daemon -H fd:// -s devicemapper --storage-opt dm.basesize=30G

OR

# devicemapper w/ segmented volumes - recommended setup
$ ps -ef |grep -i docker
docker daemon -H fd:// -s devicemapper --storage-opt dm.datadev=/dev/docker_dmapper/data --storage-opt dm.metadatadev=/dev/docker_dmapper/metadata --storage-opt dm.basesize=40G
```

2.) Docker info should return these critical components:
```sh
$ docker info
Storage Driver: devicemapper
Udev Sync Supported: true
```

Your container might be able to start with the devicemapper defaults, but won't last long.

## run w/ defaults:
```sh
$ docker run --privileged -v /lib/modules:/lib/modules:ro -p 80:80 -p 443:443 -p 4443:4443 -tdi tchughesiv/cf-mini
```
  
## run w/ custom domain & passwd:
```sh
$ docker run --privileged -v /lib/modules:/lib/modules:ro -e "NISE_DOMAIN=new.domain" -e "NISE_PASSWORD=pAsSw0rd" -p 80:80 -p 443:443 -p 4443:4443 -tdi tchughesiv/cf-mini
```
  
## run w/ docker compose
```sh
$ curl -kO https://raw.githubusercontent.com/tchughesiv/cf-mini/master/docker-compose.yml
$ docker-compose up -d
```
  
# dns:

The Dev space where your IDE/Browser/CLI are run that interface with CF must have a working internal DNS server setup for wildcard lookups against the fake "cf-mini.example" domain. Without this, you can't interact with CF outside of the Docker container.  The following is how I accomplished this on Ubuntu 15.10 (it will work on 12 & 14 also).  Similar solutions exist for other OS types. I've included a working Mac solution as well.

Ubuntu DNS server setup:
```sh
$ apt-get update && apt-get install dnsmasq

## Docker Server IP in place of 10.x.x.x
$ echo -e '\naddress=/cf-mini.example/10.x.x.x' >> /etc/dnsmasq.conf
$ dpkg-reconfigure resolvconf # (YES to dynamic)
$ /etc/init.d/dnsmasq restart
$ ping api.cf-mini.example
PING api.cf-mini.example (10.x.x.x) 56(84) bytes of data.
64 bytes from 10.x.x.x: icmp_seq=1 ttl=64 time=0.080 ms
```

Macintosh DNS server setup:
```sh
$ brew install dnsmasq
$ cp $(brew list dnsmasq | grep /dnsmasq.conf.example$) /usr/local/etc/dnsmasq.conf

## Docker Server IP in place of 10.x.x.x
$ echo -e '\naddress=/cf-mini.example/10.x.x.x' >> /usr/local/etc/dnsmasq.conf
$ sudo cp -fv /usr/local/opt/dnsmasq/*.plist /Library/LaunchDaemons/
$ sudo chown root /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
$ sudo launchctl load -w /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
$ sudo mkdir -v /etc/resolver
$ sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolver/cf-mini.example'
# DNS subdomain of cf-mini.example should be pointing to 127.0.0.1 for resolution
$ scutil --dns
resolver #2
  domain   : cf-mini.example
  nameserver[0] : 127.0.0.1
  flags    : Request A records, Request AAAA records
  reach    : Reachable,Local Address

$ sudo launchctl stop homebrew.mxcl.dnsmasq
$ sudo launchctl start homebrew.mxcl.dnsmasq
$ ping api.cf-mini.example
PING api.cf-mini.example (10.x.x.x): 56 data bytes
64 bytes from 10.x.x.x: icmp_seq=0 ttl=64 time=6.240 ms
```

# connect:

Cloud Foundry should take anywhere from 4 to 10 minutes to initialize the first time you run the container (depending on your Docker server setup).  In my tests on an Ubuntu 15.10 Docker server with 4 procs it took about 5 minutes consistently.

You'll know the stack is ready for use when you're able to access this ruby app:

http://hello.cf-mini.example/
```sh
$ curl http://hello.cf-mini.example
Hello, World!
```

To connect via cli:
```sh
$ cf login -a https://api.cf-mini.example -u admin -p c1oudc0w --skip-ssl-validation
```

CLI version 6.19.0 works well with the stack:

<https://github.com/cloudfoundry/cli/releases/tag/v6.19.0>

![gif not loading](https://raw.githubusercontent.com/tchughesiv/images/master/cfmini.gif "CF-Mini Demo")
