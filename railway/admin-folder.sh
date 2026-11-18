#!/bin/bash
# Rename the back-office folder to RAILWAY_ADMIN_FOLDER (from PS_FOLDER_ADMIN).
# Runs after the first install and on every start, so changing PS_FOLDER_ADMIN
# and redeploying moves the back office. Never fails the boot.
WEB=/var/www/html
WANT="${RAILWAY_ADMIN_FOLDER:-admin}"
[ -f "$WEB/app/config/parameters.php" ] || exit 0
[ -d "$WEB/$WANT" ] && exit 0
for dir in "$WEB"/admin*/; do
    name=$(basename "$dir")
    [ "$name" = "admin-api" ] && continue
    if [ -f "$dir/index.php" ] && [ -d "$dir/themes" ]; then
        echo "* [railway] Moving the back office from /$name/ to /$WANT/"
        mv "$WEB/$name" "$WEB/$WANT" && find "$WEB/var/cache" -mindepth 1 -maxdepth 1 -exec rm -r {} + 2>/dev/null
        exit 0
    fi
done
echo "* [railway] No back-office folder found to rename"
exit 0
