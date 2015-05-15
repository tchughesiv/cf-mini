#! /bin/sh

# NISE_IP_ADDRESS=${NISE_IP_ADDRESS:-`ip addr | grep 'inet .*global' | cut -f 6 -d ' ' | cut -f1 -d '/' | head -n 1`}
# sed -i  '/name: cflinuxfs2/,+1d' /root/cf_nise_installer/cf-release/jobs/dea_next/templates/dea.yml.erb
sed -i 's/buildpack_java/buildpack_java_offline/g' /root/cf_nise_installer/manifests/template.yml
sed -i 's/^    hm9000_noop: false/    hm9000_noop: false\n    default_app_memory: 512\n    default_app_disk_in_mb: 384/g' /root/cf_nise_installer/manifests/template.yml

echo "\naddress=/$NISE_DOMAIN/0.0.0.0" >> /etc/dnsmasq.conf
echo 'sed -i "s/${NISE_IP_ADDRESS}/0.0.0.0/g" manifests/deploy.yml' >> /root/cf_nise_installer/scripts/generate_deploy_manifest.sh
