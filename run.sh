#! /bin/bash

/var/vcap/bosh/bin/monit

sleep 3
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

# su - vcap -c "/var/vcap/data/packages/postgres/*/bin/pg_ctl reload -D /var/vcap/store/postgres"

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
        cf login -a https://api.$NISE_DOMAIN -o DevBox -u admin -p $NISE_PASSWORD --skip-ssl-validation
        cf create-space dev
        cf t -s dev
        cd /root/cf_nise_installer/test_apps/test_app/
        cf push
        echo
        echo "cf login -a https://api.$NISE_DOMAIN -u admin -p $NISE_PASSWORD --skip-ssl-validation"
        break
    fi
    sleep 5
    echo
    echo "Waiting for remaining processes to start..."
    echo
done
