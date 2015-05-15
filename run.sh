#! /bin/sh
NISE_IP_ADDRESS=${NISE_IP_ADDRESS:-`ip addr | grep 'inet .*global' | cut -f 6 -d ' ' | cut -f1 -d '/' | head -n 1`}

sed -i "/${NISE_DOMAIN}/d" /etc/dnsmasq.conf
echo "address=/$NISE_DOMAIN/$NISE_IP_ADDRESS" >> /etc/dnsmasq.conf
/etc/init.d/dnsmasq restart

iptables -t nat -F warden-prerouting 2> /dev/null || true
# iptables -t nat -F warden-postrouting 2> /dev/null || true
iptables -t nat -A warden-prerouting -d 0.0.0.0/32 -j DNAT --to-destination $NISE_IP_ADDRESS
# iptables -t nat -A warden-postrouting -s $NISE_IP_ADDRESS/32 -j SNAT --to-source 0.0.0.0
# iptables -t nat -A warden-prerouting -d 127.0.0.1/32 -j DNAT --to-destination $NISE_IP_ADDRESS
# sed 's/echo 1 \> \/proc\/sys\/net\/ipv4\/ip_forward/echo 1 \> \/proc\/sys\/net\/ipv4\/ip_forward\nNISE_IP_ADDRESS=${NISE_IP_ADDRESS:-`ip addr | grep 'inet .*global' | cut -f 6 -d ' ' | cut -f1 -d '/' | head -n 1`}\niptables -t nat -A warden-prerouting -d 0.0.0.0/32 -j DNAT --to-destination $NISE_IP_ADDRESS/g' /var/vcap/data/packages/warden/724f030f2d6e90d02c2afbe90ed5fe1ce2de1667/warden/root/linux/net.sh
# /var/vcap/data/packages/dea_next/b2fac8dac45fe1796cc982860b8549bbe78ca55f/vendor/cache/warden-ad18bff7dc56/warden/root/linux/net.sh
# /var/vcap/data/packages/warden/724f030f2d6e90d02c2afbe90ed5fe1ce2de1667/warden/root/linux/net.sh

/var/vcap/bosh/bin/monit
echo "Starting postres job..."
/var/vcap/bosh/bin/monit start postgres
sleep 30
echo "Starting nats job..."
/var/vcap/bosh/bin/monit start nats
sleep 30
echo "Starting remaining jobs..."
/var/vcap/bosh/bin/monit start all
