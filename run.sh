#! /bin/sh
/etc/init.d/dnsmasq restart
cd /root/cf_nise_installer
./scripts/start.sh
