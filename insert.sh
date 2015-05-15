#! /bin/sh
file1=/var/vcap/data/packages/warden/724f030f2d6e90d02c2afbe90ed5fe1ce2de1667/warden/root/linux/net.sh
file2=/var/vcap/data/packages/dea_next/b2fac8dac45fe1796cc982860b8549bbe78ca55f/vendor/cache/warden-ad18bff7dc56/warden/root/linux/net.sh

cp -p $file1 $file1.bak
cp -p $file2 $file2.bak

while read line
do
        echo $line
        echo $line | grep -q "echo 1 > /proc/sys/net/ipv4/ip_forward"
        [ $? -eq 0 ] && echo "NISE_IP_ADDRESS=${NISE_IP_ADDRESS:-`ip addr | grep 'inet .*global' | cut -f 6 -d ' ' | cut -f1 -d '/' | head -n 1`}
iptables -t nat -A warden-prerouting -d 0.0.0.0/32 -j DNAT --to-destination $NISE_IP_ADDRESS"
done < $file1 > $file1.new

while read line
do
        echo $line
        echo $line | grep -q "echo 1 > /proc/sys/net/ipv4/ip_forward"
        [ $? -eq 0 ] && echo "NISE_IP_ADDRESS=${NISE_IP_ADDRESS:-`ip addr | grep 'inet .*global' | cut -f 6 -d ' ' | cut -f1 -d '/' | head -n 1`}
iptables -t nat -A warden-prerouting -d 0.0.0.0/32 -j DNAT --to-destination $NISE_IP_ADDRESS"
done < $file2 > $file2.new

chmod +x $file1.new $file2.new

mv $file1.new $file1
mv $file2.new $file2
