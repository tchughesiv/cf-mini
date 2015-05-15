#! /bin/sh
rm -rf /var/lib/apt/lists/* /var/vcap/data/packages/buildpack_go /var/vcap/data/packages/buildpack_java /var/vcap/data/packages/buildpack_php /var/vcap/data/packages/buildpack_python /root/cf_nise_installer/cf-release/.final_builds
apt-get clean
