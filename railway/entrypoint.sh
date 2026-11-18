#!/bin/bash
# Railway wrapper around the official PrestaShop entrypoint (/tmp/docker_run.sh).
set -e
WEB=/var/www/html
export PORT="${PORT:-8080}"

fail() { echo "* [railway] ERROR: $*" >&2; sleep 30; exit 1; }

# Never install with the image's demo credentials.
[ -n "$ADMIN_MAIL" ] && [ "$ADMIN_MAIL" != "demo@prestashop.com" ] || fail "set ADMIN_MAIL to your own email address"
[ -n "$ADMIN_PASSWD" ] && [ "$ADMIN_PASSWD" != "prestashop_demo" ] || fail "set ADMIN_PASSWD (the template generates one)"
[ "$DB_SERVER" != "<to be defined>" ] && [ -n "$DB_SERVER" ] || fail "DB_SERVER is not set"

# The PrestaShop 9 installer needs the admin folder to be called "admin" while it runs.
# Keep the folder the deployer asked for in RAILWAY_ADMIN_FOLDER; admin-folder.sh renames it.
export RAILWAY_ADMIN_FOLDER="${PS_FOLDER_ADMIN:-admin}"
case "$RAILWAY_ADMIN_FOLDER" in *[!A-Za-z0-9_-]*|"") fail "PS_FOLDER_ADMIN may only use letters, digits, - and _";; esac
export PS_FOLDER_ADMIN=admin

# Apache must listen on Railway's PORT, with the prefork MPM that mod_php needs.
# (Railway's image unpacking can leave an mpm_event link behind: "More than one MPM loaded".)
sed -i "s/^Listen [0-9]*$/Listen ${PORT}/" /etc/apache2/ports.conf
sed -i "s/<VirtualHost \*:[0-9]*>/<VirtualHost *:${PORT}>/" /etc/apache2/sites-available/000-default.conf
rm -f /etc/apache2/mods-enabled/mpm_event.* /etc/apache2/mods-enabled/mpm_worker.*
[ -e /etc/apache2/mods-enabled/mpm_prefork.load ] || a2enmod -q mpm_prefork

# Volume housekeeping: Railway volumes are a fresh ext4 root owned by root.
[ -d "$WEB/lost+found" ] && rm -r "$WEB/lost+found"
chown www-data:www-data "$WEB"
if [ -f "$WEB/install.lock" ] && [ ! -f "$WEB/app/config/parameters.php" ] && [ ! -f "$WEB/config/settings.inc.php" ]; then
    echo "* [railway] Removing a stale install.lock left by an interrupted first install"
    rm "$WEB/install.lock"
fi

# Version notice: the shop's files live on the volume, so a new image doesn't replace them.
if [ -f "$WEB/app/config/parameters.php" ]; then
    INSTALLED=$(sed -n "s/.*const VERSION = '\([^']*\)'.*/\1/p" "$WEB/src/Core/Version.php" 2>/dev/null || true)
    IMAGE_VER="${PS_VERSION%%-*}"
    if [ -n "$INSTALLED" ] && [ "$INSTALLED" != "$IMAGE_VER" ]; then
        echo "* [railway] Shop files are PrestaShop $INSTALLED, this image ships $IMAGE_VER."
        echo "* [railway] Your files are kept. Upgrade the shop itself with the Update Assistant module in the back office."
    fi
fi

# Answer Railway's health check while files are copied and the shop installs
# (several minutes on the first deploy). init.sh stops this before Apache starts.
php -S "0.0.0.0:${PORT}" /opt/railway/health-router.php >/dev/null 2>&1 &
echo $! > /run/railway-health.pid

exec docker-php-entrypoint "$@"
