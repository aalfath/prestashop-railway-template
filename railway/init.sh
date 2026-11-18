#!/bin/bash
# Runs on every start, just before Apache (docker_run.sh's /tmp/init-scripts hook).
# Keeps the shop's domain and SSL flag in line with PS_DOMAIN / PS_ENABLE_SSL,
# fixes the back-office folder name, then stops the temporary health responder.
# Never fails the boot.
WEB=/var/www/html
P="${DB_PREFIX:-ps_}"

if [ -f "$WEB/app/config/parameters.php" ]; then
    /opt/railway/admin-folder.sh
    export MYSQL_PWD="$DB_PASSWD"
    q() { mysql -h "$DB_SERVER" -P "${DB_PORT:-3306}" -u "$DB_USER" "$DB_NAME" -N -B -e "$1"; }
    if [[ "$PS_DOMAIN" =~ ^[A-Za-z0-9.-]+(:[0-9]+)?$ ]]; then
        CUR=$(q "SELECT domain_ssl FROM ${P}shop_url WHERE main=1 LIMIT 1;" 2>/dev/null)
        if [ -n "$CUR" ] && [ "$CUR" != "$PS_DOMAIN" ]; then
            echo "* [railway] Shop domain: $CUR -> $PS_DOMAIN"
            q "UPDATE ${P}shop_url SET domain='$PS_DOMAIN', domain_ssl='$PS_DOMAIN' WHERE main=1;
               UPDATE ${P}configuration SET value='$PS_DOMAIN' WHERE name IN ('PS_SHOP_DOMAIN','PS_SHOP_DOMAIN_SSL');" \
              && find "$WEB/var/cache" -mindepth 1 -maxdepth 1 -exec rm -r {} + 2>/dev/null
        fi
    fi
    if [ "${PS_ENABLE_SSL:-1}" = "1" ]; then
        q "UPDATE ${P}configuration SET value='1' WHERE name = 'PS_SSL_ENABLED';" 2>/dev/null
    fi
    unset MYSQL_PWD
fi

if [ -f /run/railway-health.pid ]; then
    kill "$(cat /run/railway-health.pid)" 2>/dev/null
    rm /run/railway-health.pid
    sleep 1
fi
exit 0
