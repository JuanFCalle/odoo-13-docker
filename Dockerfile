FROM debian:buster-slim

# Install dependencies.
RUN set -x; \
        apt-get update \
        && apt-get install -y --no-install-recommends \
            ca-certificates \
            curl \
            dirmngr \
            fonts-noto-cjk \
            gnupg \
            libssl-dev \
            node-less \
            npm \
            python3-num2words \
            python3-pip \
            python3-phonenumbers \
            python3-pyldap \
            python3-qrcode \
            python3-renderpm \
            python3-setuptools \
            python3-slugify \
            python3-vobject \
            python3-watchdog \
            python3-xlrd \
            python3-xlwt \
            xz-utils \
        && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.stretch_amd64.deb \
        && echo '7e35a63f9db14f93ec7feeb0fce76b30c08f2057 wkhtmltox.deb' | sha1sum -c - \
        && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
        && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# Install Odoo
ENV ODOO_VERSION 13.0
ARG ODOO_RELEASE=20200121
ARG ODOO_SHA=770d71cfafb9a8f8419b88f8033b964d5742ad57
RUN set -x; \
        curl -o odoo.deb -sSL http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/odoo_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb \
        && echo "${ODOO_SHA} odoo.deb" | sha1sum -c - \
        && dpkg --force-depends -i odoo.deb \
        && apt-get update \
        && apt-get -y install -f --no-install-recommends \
        && rm -rf /var/lib/apt/lists/* odoo.deb

# Copy entrypoint script and set executable permissions
COPY ./entrypoint.sh /
RUN chmod +x entrypoint.sh

# Copy Odoo configuration file
COPY ./config/odoo.conf /etc/odoo/

# Set permissions to /etc/odoo/odoo.conf
RUN chown odoo /etc/odoo/odoo.conf

# Create extra add-ons directories and set permissions
RUN mkdir -p /mnt/extra-addons \
    && chown -R odoo /mnt/extra-addons

# Set default config file
ENV ODOO_RC /etc/odoo/odoo.conf

# Set default user
USER odoo

# Set default command
ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo", "-d", "prueba"]
