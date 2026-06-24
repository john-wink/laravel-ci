# PHP-Version zentral – für ein Upgrade nur diesen Wert ändern (oder via --build-arg überschreiben)
ARG PHP_VERSION=8.5

FROM shivammathur/node:php-${PHP_VERSION}-noble

# Achtung: ARGs vor FROM sind NACH FROM nicht mehr sichtbar – hier neu deklarieren,
# damit ${PHP_VERSION} auch in den RUN-Schritten unten verfügbar ist.
ARG PHP_VERSION

USER root

# Install missing PHP extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-sqlite3 \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-exif \
    php${PHP_VERSION}-imagick \
    imagemagick \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Disable Xdebug + PCOV (performance)
RUN if [ -f /etc/php/${PHP_VERSION}/cli/conf.d/20-xdebug.ini ]; then \
      mv /etc/php/${PHP_VERSION}/cli/conf.d/20-xdebug.ini /etc/php/${PHP_VERSION}/cli/conf.d/20-xdebug.ini.disabled; \
    fi \
    && printf "pcov.enabled=0\n" > /etc/php/${PHP_VERSION}/cli/conf.d/99-disable-pcov.ini

WORKDIR /app
