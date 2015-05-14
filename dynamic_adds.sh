#! /bin/sh

NISE_IP_ADDRESS=${NISE_IP_ADDRESS:-`ip addr | grep 'inet .*global' | cut -f 6 -d ' ' | cut -f1 -d '/' | head -n 1`}

sed -i 's/buildpack_java/buildpack_java_offline/g' /root/cf_nise_installer/manifests/template.yml
sed -i 's/^    hm9000_noop: false/    hm9000_noop: false\n    default_app_memory: 512\n    default_app_disk_in_mb: 384/g' /root/cf_nise_installer/manifests/template.yml
sed -i 's/^\- rootfs_cflinuxfs2//g' /root/cf_nise_installer/cf-release/jobs/dea_next/spec

echo -e '\naddress=/$NISE_DOMAIN/$NISE_IP_ADDRESS' >> /etc/dnsmasq.conf
