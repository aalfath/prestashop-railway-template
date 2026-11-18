<?php
// Temporary responder while the container copies files and installs PrestaShop.
// railway/init.sh stops it right before Apache starts.
if (strpos($_SERVER['REQUEST_URI'], '/healthz') === 0) {
    echo "ok (starting)\n";
    return true;
}
http_response_code(503);
header('Retry-After: 30');
header('Content-Type: text/plain');
echo "PrestaShop is starting. The first deploy installs the shop and takes a few minutes. Reload shortly.\n";
return true;
