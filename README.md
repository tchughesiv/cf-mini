# CF Mini
Docker image running Cloud Foundry stack - listens on ports 80/443/4443

[![](https://badge.imagelayers.io/tchughesiv/cf-mini.svg)](https://imagelayers.io/?images=tchughesiv/cf-mini:latest 'Get your own badge on imagelayers.io')

    Ubuntu Precise 12.04.05
    Cloud Foundry v205

Cloud Foundry aims to make development easy but can be complex to stand up a working local stack.

CF Mini makes it a 2-step process... Pull & Run with Docker.

Pull:
```shell
docker pull tchughesiv/cf-mini
```

Run:
```shell
$ docker run --privileged -p 80:80 -p 443:443 -p 4443:4443 -tdi tchughesiv/cf-mini
```

		CLI version 6.11.2 works well with the stack
		https://github.com/cloudfoundry/cli/releases/tag/v6.11.2

IMPORTANT:

  Your Dev space must have a working internal DNS server setup for wildcard lookups against the "cf.mini" domain.  The following is how I accomplished this on my Mac.  Similar solutions exist for other OS types (the following works for Ubuntu as well, albeit w/ a slightly different implementation). I'll try to add other examples to this page over time.

Macintosh setup:
```shell
$ brew install dnsmasq
$ cp $(brew list dnsmasq | grep /dnsmasq.conf.example$) /usr/local/etc/dnsmasq.conf

# INTERNAL BOOT2DOCKER (IP may differ for you)
$ echo -e '\naddress=/cf.mini/192.168.59.103' >> /usr/local/etc/dnsmasq.conf

# OR EXTERNAL SERVER
# echo -e '\naddress=/cf.mini/10.x.x.x' >> /usr/local/etc/dnsmasq.conf

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
PING api.cf.mini (192.168.59.103): 56 data bytes
64 bytes from 192.168.59.103: icmp_seq=0 ttl=64 time=6.240 ms
```

Cloud Foundry should take anywhere from 3 to 10 minutes to initialize the first time you run the container (depending on your Docker server setup).  In my tests on an Ubuntu 15.04 server with 4 procs it took about 4 minutes consistently.  Subsequent (existing) container runs will be much faster to start.

  You'll know the stack is ready for use when you're able to access this ruby app:
  http://hello.cf.mini/

    "Hello, World!"

To connect via cli:
```shell
$ cf login -a https://api.cf.mini -u admin -p c1oudc0w --skip-ssl-validation
```
