# cf-mini
Docker image running Cloud Foundry stack - listens on ports 80/443/4443

[![](https://badge.imagelayers.io/tchughesiv/cf-mini.svg)](https://imagelayers.io/?images=tchughesiv/cf-mini:latest 'Get your own badge on imagelayers.io')

    Ubuntu Precise 12.04.05
    Cloud Foundry v205

To run:
```shell
docker run --privileged -p 80:80 -p 443:443 -p 4443:4443 -tdi tchughesiv/cf-mini
```

		CF cli 6.11.2 works well with the stack
		https://github.com/cloudfoundry/cli/releases/tag/v6.11.2

IMPORTANT:
	Must have a working wildcard DNS server setup for the domain "cf.mini."  The following is how I accomplished this on my Mac.  Similar solutions exist for other OS types (the following works for Ubuntu as well, albeit w/ a slightly different implementation). I'll try to add other examples to this page over time.

Macintosh local wildcard domain
```shell
brew install dnsmasq
cp $(brew list dnsmasq | grep /dnsmasq.conf.example$) /usr/local/etc/dnsmasq.conf

INTERNAL BOOT2DOCKER (IP may differ for you)
echo -e '\naddress=/cf.mini/192.168.59.103' >> /usr/local/etc/dnsmasq.conf

# OR EXTERNAL SERVER
# echo -e '\naddress=/cf.mini/10.x.x.x' >> /usr/local/etc/dnsmasq.conf

sudo cp -fv /usr/local/opt/dnsmasq/*.plist /Library/LaunchDaemons/
sudo chown root /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
sudo launchctl load -w /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
sudo mkdir -v /etc/resolver
sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolver/cf.mini'
scutil --dns

sudo launchctl stop homebrew.mxcl.dnsmasq
sudo launchctl start homebrew.mxcl.dnsmasq

$ ping api.cf.mini
PING api.cf.mini (192.168.59.103): 56 data bytes
64 bytes from 192.168.59.103: icmp_seq=0 ttl=64 time=6.240 ms
```
