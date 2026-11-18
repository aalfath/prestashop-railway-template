# PrestaShop on Railway: official image, pinned by version and digest.
# Bump the tag and digest together, then add a CHANGELOG.md entry.
FROM prestashop/prestashop:9.2.1-apache@sha256:fb3758bb6d7cb14ff1163029c094af09607ae02727f70dac7eecb4fe0d6f0b01

# Safe defaults for an unattended first install. The template sets the rest
# (database, admin email and password, domain). The image's demo password and
# demo admin email are rejected by railway/entrypoint.sh.
ENV PORT=8080 \
    PS_INSTALL_AUTO=1 \
    PS_INSTALL_DB=0 \
    PS_ERASE_DB=0 \
    PS_ENABLE_SSL=1 \
    PS_HANDLE_DYNAMIC_DOMAIN=0 \
    PS_FOLDER_INSTALL=install \
    PS_LANGUAGE=en \
    PS_COUNTRY=US

COPY railway/ /opt/railway/
RUN chmod 755 /opt/railway/*.sh \
 && mkdir -p /tmp/init-scripts /tmp/post-install-scripts \
 && ln -s /opt/railway/init.sh /tmp/init-scripts/50-railway.sh \
 && ln -s /opt/railway/admin-folder.sh /tmp/post-install-scripts/50-railway-admin.sh \
 && cp /opt/railway/apache-railway.conf /etc/apache2/conf-enabled/railway.conf

EXPOSE 8080
ENTRYPOINT ["/opt/railway/entrypoint.sh"]
CMD ["/tmp/docker_run.sh"]
