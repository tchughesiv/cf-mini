#! /bin/bash
echo Etc/UTC > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata

awk 'NR>1 {print $1}' /proc/cgroups |
while read -r a
do
  b="/tmp/warden/cgroup/$a"
  mkdir -p "$b"
done

mount -tcgroup -operf_event cgroup:perf_event /tmp/warden/cgroup/perf_event
mount -tcgroup -omemory cgroup:memory /tmp/warden/cgroup/memory
mount -tcgroup -oblkio cgroup:blkio /tmp/warden/cgroup/blkio
mount -tcgroup -ohugetlb cgroup:hugetlb /tmp/warden/cgroup/hugetlb
mount -tcgroup -onet_cls,net_prio cgroup:net_prio /tmp/warden/cgroup/net_prio
mount -tcgroup -onet_cls,net_prio cgroup:net_cls /tmp/warden/cgroup/net_cls
mount -tcgroup -ocpu,cpuacct cgroup:cpu /tmp/warden/cgroup/cpu
mount -tcgroup -ocpu,cpuacct cgroup:cpuacct /tmp/warden/cgroup/cpuacct
mount -tcgroup -ocpuset cgroup:cpuset /tmp/warden/cgroup/cpuset
mount -tcgroup -odevices cgroup:devices /tmp/warden/cgroup/devices
mount -tcgroup -ofreezer cgroup:perf_event /tmp/warden/cgroup/freezer

. ~/.profile
cd /root/cf_nise_installer/
./scripts/install_cf_release.sh
# sed -i "s/grep -q '\/instance' \/proc\/self\/cgroup/grep -q '\/docker' \/proc\/self\/cgroup/g" /var/vcap/packages/common/utils.sh

rsyslogd
NISE_IP_ADDRESS=${NISE_IP_ADDRESS:-`ip addr | grep 'inet .*global' | cut -f 6 -d ' ' | cut -f1 -d '/' | head -n 1`}
sed -i "/${NISE_DOMAIN}/d" /etc/dnsmasq.conf
sed -i "/cf.internal/d" /etc/dnsmasq.conf
echo "address=/$NISE_DOMAIN/$NISE_IP_ADDRESS" >> /etc/dnsmasq.conf
# comment out now that consul works???
echo "address=/cf.internal/$NISE_IP_ADDRESS" >> /etc/dnsmasq.conf

cp -p /etc/resolv.conf /etc/resolv.old
grep -i nameserver /etc/resolv.old > /etc/resolv.dnsmasq.conf
echo "nameserver 8.8.8.8
nameserver 8.8.4.4" >> /etc/resolv.dnsmasq.conf
sed -i "/^resolv-file/d" /etc/dnsmasq.conf
echo "resolv-file=/etc/resolv.dnsmasq.conf" >> /etc/dnsmasq.conf
echo "# Enable forward lookup of the 'consul' domain:
server=/consul/127.0.0.1#8600" > /etc/dnsmasq.d/10-consul

umount /etc/resolv.conf
# required for consul code checks
resolvconf_head=/etc/resolvconf/resolv.conf.d/head
resolvconf_base=/etc/resolvconf/resolv.conf.d/base
echo "nameserver 127.0.0.1" > $resolvconf_head
grep -i nameserver /etc/resolv.dnsmasq.conf > $resolvconf_base
cat $resolvconf_head > /etc/resolv.conf
cat $resolvconf_base >> /etc/resolv.conf
/etc/init.d/dnsmasq restart

find /var/vcap/jobs/*/bin/ -type f | xargs sed -i '/tcp_fin_timeout/a echo' ;
find /var/vcap/jobs/*/bin/ -type f | xargs sed -i '/tcp_tw_recycle/a echo' ;
find /var/vcap/jobs/*/bin/ -type f | xargs sed -i '/tcp_tw_reuse/a echo' ;
find /var/vcap/jobs/*/bin/ -type f | xargs sed -i '/net.ipv4.neigh.default.gc_thresh/a echo' ;

find /var/vcap/jobs/*/bin/ -type f | xargs sed -i '/tcp_fin_timeout/d' ;
find /var/vcap/jobs/*/bin/ -type f | xargs sed -i '/tcp_tw_recycle/d' ;
find /var/vcap/jobs/*/bin/ -type f | xargs sed -i '/tcp_tw_reuse/d' ;
find /var/vcap/jobs/*/bin/ -type f | xargs sed -i '/net.ipv4.neigh.default.gc_thresh/d' ;

sed -i 's/peer-heartbeat-timeout/peer-heartbeat-interval/g' /var/vcap/jobs/etcd/bin/etcd_ctl
sed -i 's/peer-heartbeat-timeout/peer-heartbeat-interval/g' /var/vcap/jobs/etcd/templates/etcd_ctl.erb

# sed -i 's/0.0.0.0/*/g' /var/vcap/jobs/postgres/config/postgresql.conf
# sed -i 's/shared_buffers = 128MB/shared_buffers = 256MB/g' /var/vcap/jobs/postgres/config/postgresql.conf

# sed -i 's/0.0.0.0/*/g' /var/vcap/jobs/postgres/bin/postgres_ctl
sed -i '/kernel.shmmax/d' /var/vcap/jobs/postgres/bin/postgres_ctl

# echo "log_min_messages = ERROR
# wal_buffers = 8MB
# checkpoint_completion_target = 0.7
# checkpoint_timeout = 10min
# checkpoint_segments = 20" >> /var/vcap/jobs/postgres/config/postgresql.conf

/var/vcap/bosh/bin/monit quit
/var/vcap/bosh/bin/monit

# cp -p /var/vcap/jobs/consul_agent/config/config.json /var/vcap/jobs/consul_agent/config/config.new.json
# sed -i 's/,"services"/,"ports":{"dns":8600},"services"/g' /var/vcap/jobs/consul_agent/confab.json
# sed -i 's/{"dns":53}/{"dns":8600}/g' /var/vcap/jobs/consul_agent/config/config.json
# sed -i "s/${NISE_IP_ADDRESS}/127.0.0.1/g" /var/vcap/jobs/consul_agent/config/config.json
# cp -rp /var/vcap/jobs/consul_agent/config /var/vcap/jobs/consul_agent/config.new

echo "Starting postres job..."
/var/vcap/bosh/bin/monit start postgres

echo
echo "Waiting for postgres to start..."
echo
for ((i=0; i < 120; i++)); do
    if ! (/var/vcap/bosh/bin/monit summary | tail -n +3 | grep -i postgres | grep -v -E "(running|accessible)$"); then
        break
    fi
    sleep 5
    echo
    echo "Waiting for postgres to start..."
    echo
done

echo "Starting nats job..."
/var/vcap/bosh/bin/monit start nats

echo
echo "Waiting for nats to start..."
echo
for ((i=0; i < 120; i++)); do
    if ! (/var/vcap/bosh/bin/monit summary | tail -n +3 | grep -i nats | grep -v -E "(running|accessible)$"); then
        break
    fi
    sleep 5
    echo
    echo "Waiting for nats to start..."
    echo
done

echo "Starting remaining jobs..."
/var/vcap/bosh/bin/monit start all

echo
echo "Waiting for remaining processes to start..."
echo
for ((i=0; i < 120; i++)); do
    if ! (/var/vcap/bosh/bin/monit summary | tail -n +3 | grep -v -E "(running|accessible)$"); then
        break
    fi
    sleep 5
    echo
    echo "Waiting for remaining processes to start..."
    echo
done

/var/vcap/bosh/bin/monit quit
/var/vcap/bosh/bin/monit stop all
/var/vcap/bosh/bin/monit stop all
/var/vcap/bosh/bin/monit stop all
/var/vcap/bosh/bin/monit stop all