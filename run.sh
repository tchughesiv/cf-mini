#! /bin/sh
. ~/.profile
cd /root/cf_nise_installer/
./scripts/install_cf_release.sh
sed -i "s/grep -q '\/instance' \/proc\/self\/cgroup/grep -q '\/docker' \/proc\/self\/cgroup/g" /var/vcap/packages/common/utils.sh

rsyslogd
NISE_IP_ADDRESS=${NISE_IP_ADDRESS:-`ip addr | grep 'inet .*global' | cut -f 6 -d ' ' | cut -f1 -d '/' | head -n 1`}
sed -i "/${NISE_DOMAIN}/d" /etc/dnsmasq.conf
echo "address=/$NISE_DOMAIN/$NISE_IP_ADDRESS" >> /etc/dnsmasq.conf

umount /etc/resolv.conf
echo "nameserver 127.0.0.1
nameserver 8.8.8.8
nameserver 8.8.4.4" > /etc/resolv.conf
/etc/init.d/dnsmasq restart

# iptables -t nat -F PREROUTING 2> /dev/null || true
# iptables -t nat -F POSTROUTING 2> /dev/null || true
# iptables -t nat -A PREROUTING -d 0.0.0.0/32 -j DNAT --to-destination $NISE_IP_ADDRESS
# iptables -t nat -A POSTROUTING -s $NISE_IP_ADDRESS/32 -j SNAT --to-source 0.0.0.0
sed -i '/tcp_fin_timeout/d' /var/vcap/jobs/gorouter/bin/gorouter_ctl
sed -i '/tcp_tw_recycle/d' /var/vcap/jobs/gorouter/bin/gorouter_ctl
sed -i '/tcp_tw_reuse/d' /var/vcap/jobs/gorouter/bin/gorouter_ctl

sed -i '/tcp_fin_timeout/d' /var/vcap/jobs/dea_next/bin/dea_ctl
sed -i '/tcp_tw_recycle/d' /var/vcap/jobs/dea_next/bin/dea_ctl
sed -i '/tcp_tw_reuse/d' /var/vcap/jobs/dea_next/bin/dea_ctl

/var/vcap/bosh/bin/monit
/var/vcap/bosh/bin/monit -I
sleep 2
echo "Starting postres job..."
/var/vcap/bosh/bin/monit start postgres
sleep 30
echo "Starting nats job..."
/var/vcap/bosh/bin/monit start nats
sleep 20
echo "Starting etcd job..."
/var/vcap/bosh/bin/monit start etcd
sleep 10
echo "Starting remaining jobs..."
/var/vcap/bosh/bin/monit start all
# iptables -t nat -L
# watch -n 3 '/var/vcap/bosh/bin/monit summary'

echo "Waiting for all processes to start"
for ((i=0; i < 120; i++)); do
    if ! (sudo /var/vcap/bosh/bin/monit summary | tail -n +3 | grep -v -E "running$"); then
        cf login -a https://api.$NISE_DOMAIN -u admin -p $NISE_PASSWORD --skip-ssl-validation
		cf create-space dev
		cf t -s dev
    fi
    sleep 10
done
