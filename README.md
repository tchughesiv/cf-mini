# CF Mini
Docker image running Cloud Foundry stack - listens on ports 80/443/4443

[![](https://badge.imagelayers.io/tchughesiv/cf-mini.svg)](https://imagelayers.io/?images=tchughesiv/cf-mini:latest 'Get your own badge on imagelayers.io')

    Ubuntu Precise 12.04.05
    Cloud Foundry v205

Cloud Foundry aims to simplify code deployments... once you have a working PaaS stack anyway. Accomplishing this initial setup/install task of the stack itself, however, can be cumbersome.

CF Mini makes it a 2-step process... Pull & Run with Docker.

# pull:

    $ docker pull tchughesiv/cf-mini

# run:

    $ docker run --privileged -p 80:80 -p 443:443 -p 4443:4443 -tdi tchughesiv/cf-mini

# requirements:

Tested on Ubuntu 15.04 Docker Server w/ following:

  Instructions -

  <https://github.com/tchughesiv/cf-mini/blob/master/ubuntu15_04.md>

  A Docker server running with "devicemapper" as its storage backend (with Udev sync = true) & at least 30gb disk highly recommended. I intend to do further testing with the btrfs and overlay storage options soon. My working Ubuntu environment has two critical things configured that you should verify or performance will suffer:

  Server process looks like this:

    $ ps -ef |grep -i docker
    docker -d -s devicemapper --storage-opt dm.basesize=30G

  Docker info returns these critical components:

    $ docker info
    Storage Driver: devicemapper
     Data Space Available: 30 GB
     Udev Sync Supported: true

  Your container might be able to start with the defaults, but won't last long... if it runs at all. At the very least, change to devicemapper w/o udev or base size changes (full storage might bite you fast though). I intend to put a document together for building a Docker server like stated above.  Check back soon if you need help.

# dns:

  The Dev space where your IDE/Browser/CLI are run that interface with CF must have a working internal DNS server setup for wildcard lookups against the fake "cf.mini" domain. Without this, you can't interact with CF outside of the Docker container.  The following is how I accomplished this on Ubuntu 15.04 (it will work on 12 & 14 also).  Similar solutions exist for other OS types. I've included a working Mac solution as well.

Ubuntu DNS server setup:

    $ apt-get update && apt-get install dnsmasq

    ## Docker Server IP in place of 10.x.x.x
    $ echo -e '\naddress=/cf.mini/10.x.x.x' >> /etc/dnsmasq.conf
    $ dpkg-reconfigure resolvconf # (YES to dynamic)
    $ /etc/init.d/dnsmasq restart
    $ ping api.cf.mini
    PING api.cf.mini (10.x.x.x) 56(84) bytes of data.
    64 bytes from 10.x.x.x: icmp_seq=1 ttl=64 time=0.080 ms

Macintosh DNS server setup:

    $ brew install dnsmasq
    $ cp $(brew list dnsmasq | grep /dnsmasq.conf.example$) /usr/local/etc/dnsmasq.conf

    ## Docker Server IP in place of 10.x.x.x
    $ echo -e '\naddress=/cf.mini/10.x.x.x' >> /usr/local/etc/dnsmasq.conf
    $ sudo cp -fv /usr/local/opt/dnsmasq/*.plist /Library/LaunchDaemons/
    $ sudo chown root /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
    $ sudo launchctl load -w /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
    $ sudo mkdir -v /etc/resolver
    $ sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolver/cf.mini'
    # DNS subdomain of cf.mini should be pointing to 127.0.0.1 for resolution
    $ scutil --dns
    resolver #2
      domain   : cf.mini
      nameserver[0] : 127.0.0.1
      flags    : Request A records, Request AAAA records
      reach    : Reachable,Local Address

    $ sudo launchctl stop homebrew.mxcl.dnsmasq
    $ sudo launchctl start homebrew.mxcl.dnsmasq
    $ ping api.cf.mini
    PING api.cf.mini (10.x.x.x): 56 data bytes
    64 bytes from 10.x.x.x: icmp_seq=0 ttl=64 time=6.240 ms

# connect:

Cloud Foundry should take anywhere from 4 to 10 minutes to initialize the first time you run the container (depending on your Docker server setup).  In my tests on an Ubuntu 15.04 Docker server with 4 procs it took about 4 minutes consistently.

  You'll know the stack is ready for use when you're able to access this ruby app:

  <http://hello.cf.mini/>

    $ curl http://hello.cf.mini
    Hello, World!

To connect via cli:

    $ cf login -a https://api.cf.mini -u admin -p c1oudc0w --skip-ssl-validation

CLI version 6.11.2 works well with the stack:	<https://github.com/cloudfoundry/cli/releases/tag/v6.11.2>
