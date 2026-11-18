# Changelog

Deployers: read the entry for the version you're updating to before you apply a Railway update notice. Breaking changes are listed first.

## 9.2.1 (2026-11-18)

First release of this template.

- PrestaShop 9.2.1, official image `prestashop/prestashop:9.2.1-apache@sha256:fb3758bb6d7cb14ff1163029c094af09607ae02727f70dac7eecb4fe0d6f0b01` (PHP 8.5, Apache).
- Automatic first install against Railway's MySQL, with a generated admin password and a generated back-office folder name. The image's demo credentials are refused.
- Shop files on a Railway volume at `/var/www/html`; health check at `/healthz`, answered during the first install as well.
- Apache listens on `PORT`, runs only the prefork MPM, treats Railway's HTTPS proxy as HTTPS, and takes the visitor's address from `X-Real-IP` so back-office sessions stay logged in.
