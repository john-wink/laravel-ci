FROM shivammathur/node:php-8.4-noble

USER root

# Install missing PHP extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    php8.4-bcmath \
    php8.4-gd \
    php8.4-sqlite3 \
    php8.4-intl \
    php8.4-exif \
    php8.4-imagick \
    imagemagick \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Disable Xdebug + PCOV (performance)
RUN if [ -f /etc/php/8.4/cli/conf.d/20-xdebug.ini ]; then \
      mv /etc/php/8.4/cli/conf.d/20-xdebug.ini /etc/php/8.4/cli/conf.d/20-xdebug.ini.disabled; \
    fi \
    && printf "pcov.enabled=0\n" > /etc/php/8.4/cli/conf.d/99-disable-pcov.ini

WORKDIR /app