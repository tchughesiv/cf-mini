#! /bin/sh
NISE_IP_ADDRESS=${NISE_IP_ADDRESS:-`ip addr | grep 'inet .*global' | cut -f 6 -d ' ' | cut -f1 -d '/' | head -n 1`}

sed -i "/${NISE_DOMAIN}/d" /etc/dnsmasq.conf
echo "address=/$NISE_DOMAIN/$NISE_IP_ADDRESS" >> /etc/dnsmasq.conf

echo "1" > /proc/sys/net/ipv4/ip_forward
modprobe ip_tables
modprobe ip_conntrack

iptables -t nat -A PREROUTING -d $NISE_IP_ADDRESS -j DNAT --to-destination 127.0.0.1
iptables -t nat -A POSTROUTING -j MASQUERADE
iptables -t nat -L

/etc/init.d/dnsmasq restart
cd /root/cf_nise_installer
./scripts/start.sh
