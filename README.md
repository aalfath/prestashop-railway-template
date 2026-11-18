[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/prestashop-1?utm_medium=integration&utm_source=button&utm_campaign=prestashop)

# Deploy and Host PrestaShop on Railway

PrestaShop is a free, open-source e-commerce platform written in PHP. It runs a full online store: a storefront with themes, a product catalog, cart and checkout, payments and shipping through modules, and a back office for orders, customers, stock and statistics. This template deploys PrestaShop 9.2.1 with a MySQL database.

## About Hosting PrestaShop

PrestaShop needs a PHP web server, a MySQL database and persistent storage for its files: product images, installed modules and themes, and its configuration all live in the web root. This template builds the official `prestashop/prestashop` Apache image, pinned by version and digest, from a public GitHub repo, and mounts a Railway volume on `/var/www/html`. On the first deploy the container installs the shop on its own, which takes about four to five minutes, and a health check answers while it runs. The admin password and the back-office folder name are generated, and the admin email is the only value you enter.

## Common Use Cases

* Run your own online store without monthly platform fees or a per-sale commission
* Try PrestaShop, its themes and its modules on a real HTTPS domain before you go live
* Host a catalog or B2B shop that you can extend with PHP modules

## Dependencies for PrestaShop Hosting

* MySQL (Railway's MySQL service, included)
* A Railway volume for the shop's files (included)

### Deployment Dependencies

* PrestaShop source and releases: https://github.com/PrestaShop/PrestaShop/releases
* Official Docker image: https://hub.docker.com/r/prestashop/prestashop
* PrestaShop documentation: https://docs.prestashop-project.org/
* This template's repo: https://github.com/aalfath/prestashop-railway-template

### Implementation Details

You enter one value at deploy: `ADMIN_MAIL`, the email address you log in with. Everything else is set for you:

| Variable | Value | Notes |
|---|---|---|
| `ADMIN_PASSWD` | generated, 24 characters | Read it in the PrestaShop service's Variables tab. Change it in the back office after you log in. |
| `PS_FOLDER_ADMIN` | `admin` plus 8 random characters | The back office is at `https://YOUR-DOMAIN/` followed by this value. Change it and redeploy to move the back office. |
| `PS_DOMAIN` | the Railway domain | Update it when you add a custom domain, then redeploy: the shop's domain is rewritten in the database at start. |
| `DB_*` | references to the MySQL service | |

After the first deploy:

1. Wait for the deploy log to show `Installation successful`, then open the public URL for the storefront.
2. Open `https://YOUR-DOMAIN/` followed by the value of `PS_FOLDER_ADMIN`, and log in with `ADMIN_MAIL` and `ADMIN_PASSWD`.
3. Set up your shop name, payments, shipping and email (SMTP) in the back office. The default language is English and the default country is the United States; add more languages under International.

Optional settings: `PS_LANGUAGE` and `PS_COUNTRY` (before the first deploy only, for example `fr` and `FR`), `PS_ENABLE_SSL` (`1` by default).

**Updates.** The shop's files live on the volume, so a newer image doesn't overwrite your shop. When this template moves to a new PrestaShop release, Railway shows an update notice; applying it updates the PHP and Apache runtime, and the deploy log says when your shop files are older than the image. Upgrade the shop itself with PrestaShop's Update Assistant module in the back office, after a backup of the volume and the database. See `CHANGELOG.md` in the repo before you apply an update.

## Why Deploy PrestaShop on Railway?

<!-- Recommended: Keep this section as shown below -->
Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying PrestaShop on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
<!-- End recommended section -->
