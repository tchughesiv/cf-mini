#! /bin/bash
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

find /var/vcap/jobs/*/bin/ -type f | xargs sed -i '/tcp_fin_timeout/d' ;
find /var/vcap/jobs/*/bin/ -type f | xargs sed -i '/tcp_tw_recycle/d' ;
find /var/vcap/jobs/*/bin/ -type f | xargs sed -i '/tcp_tw_reuse/d' ;
find /var/vcap/jobs/*/bin/ -type f | xargs sed -i '/net.ipv4.neigh.default.gc_thresh/d' ;
sed -i 's/peer-heartbeat-timeout/peer-heartbeat-interval/g' /var/vcap/jobs/etcd/bin/etcd_ctl
sed -i 's/peer-heartbeat-timeout/peer-heartbeat-interval/g' /var/vcap/jobs/etcd/templates/etcd_ctl.erb

/var/vcap/bosh/bin/monit
/var/vcap/bosh/bin/monit -I
sleep 2
echo "Starting postres job..."
/var/vcap/bosh/bin/monit start postgres
sleep 15
echo "Starting nats job..."
/var/vcap/bosh/bin/monit start nats
sleep 15
echo "Starting etcd jobs..."
/var/vcap/bosh/bin/monit start etcd
sleep 10
# echo "Starting hm9000 jobs..."
# /var/vcap/bosh/bin/monit start hm9000_api_server hm9000_metrics_server hm9000_listener uaa uaa_cf-registrar
# sleep 10
# echo "Starting gorouter & controller jobs..."
# /var/vcap/bosh/bin/monit start gorouter haproxy cloud_controller_ng nginx_cc cloud_controller_worker_local_1 cloud_controller_clock cloud_controller_worker_1 cloud_controller_worker_local_2
# sleep 10
echo "Starting remaining jobs..."
/var/vcap/bosh/bin/monit start all
# watch -n 3 '/var/vcap/bosh/bin/monit summary'

echo "Waiting for all processes to start..."
for ((i=0; i < 120; i++)); do
    if ! (/var/vcap/bosh/bin/monit summary | tail -n +3 | grep -v -E "running$"); then
        cf login -a https://api.$NISE_DOMAIN -u admin -p $NISE_PASSWORD --skip-ssl-validation
        cf create-space dev
        cf t -s dev
        cd /root/cf_nise_installer/test_apps/spring-music/
        cf push
        break
    fi
    sleep 10
    echo
    echo "Waiting for all processes to start..."
    echo
done
