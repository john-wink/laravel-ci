# PHP-Version zentral – für ein Upgrade nur diesen Wert ändern (oder via --build-arg überschreiben)
ARG PHP_VERSION=8.5

FROM shivammathur/node:php-${PHP_VERSION}-noble

# Achtung: ARGs vor FROM sind NACH FROM nicht mehr sichtbar – hier neu deklarieren,
# damit ${PHP_VERSION} auch in den RUN-Schritten unten verfügbar ist.
ARG PHP_VERSION

USER root

# Install missing PHP extensions.
#
# `git` steht bewusst mit drin, obwohl das Basis-Image es je nach Variante schon
# mitbringt: actions/checkout benutzt git nur, wenn es auf dem PATH liegt, und
# faellt sonst auf den REST-Tarball zurueck — dann gibt es kein .git im
# Workspace. Pests TIA leitet ihren Ablageort aus dem GIT-REMOTE ab
# (`vendor/bin/pest --baseline`), der Baseline-Job wuerde also lautlos in ein
# anderes Verzeichnis schreiben oder abbrechen. apt ist idempotent: ist git
# bereits da, kostet die Zeile nichts.
RUN apt-get update && apt-get install -y --no-install-recommends \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-sqlite3 \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-exif \
    php${PHP_VERSION}-imagick \
    php${PHP_VERSION}-pcov \
    php${PHP_VERSION}-redis \
    imagemagick \
    zstd \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Laufzeitbibliotheken fuer headless Chrome.
#
# Die Suite rendert Screenshots und PDFs ueber Browsershot, das per puppeteer ein
# eigenes Chrome nach $HOME/.cache/puppeteer laedt. Das Binary ist also da — es
# findet nur seine Bibliotheken nicht:
#   chrome-headless-shell: error while loading shared libraries: libnspr4.so
#   Failed to launch the browser process: Code: 127
# Auf den VM-Runnern faellt das nie auf, weil deren Image Chrome samt Abhaengig-
# keiten mitbringt; im Container fehlt beides.
#
# Bewusst ueber Googles Paket statt einer handgeschriebenen lib-Liste: apt loest
# damit die vollstaendige Abhaengigkeitsschliessung selbst auf. Ubuntu 24.04 hat
# in der t64-Umstellung Pakete umbenannt (libasound2 -> libasound2t64,
# libcups2 -> libcups2t64, libgtk-3-0 -> libgtk-3-0t64), eine per Hand gepflegte
# Liste bricht dort still. `chromium` ist auf noble nur ein Snap-Uebergangspaket
# und im Container nicht benutzbar.
RUN install -d -m 0755 /etc/apt/keyrings \
    && curl -fsSL https://dl.google.com/linux/linux_signing_key.pub \
        | gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg \
    && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" \
        > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends google-chrome-stable fonts-liberation \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Chrome-Wrapper fuer Container-Jobs.
#
# Chrome verweigert den Start als root, wenn --no-sandbox fehlt, und diese Pruefung
# haengt NICHT an Capabilities: mit --cap-add=SYS_ADMIN scheitert er genauso
# (gemessen, Run 31129223845). Ein Container-Job laeuft als root, auf den
# VM-Runnern dagegen unter einem unprivilegierten Benutzer — deshalb faellt es nur
# hier auf.
#
# Der Wrapper wird per PUPPETEER_EXECUTABLE_PATH gesetzt und gilt damit fuer JEDE
# Browsershot-Aufrufstelle, auch fuer kuenftige. Die Alternative waere, --no-sandbox
# in den Anwendungscode zu schreiben — eine reine CI-Eigenheit an einer Stelle, die
# in Produktion (Lambda) gar nicht laeuft, und man muesste jede neue Aufrufstelle
# daran erinnern.
#
# --disable-dev-shm-usage steht mit drin, weil ein Container 64 MB /dev/shm hat.
# Das allein war NICHT die Ursache (ein Lauf mit --shm-size=2g brachte dasselbe
# Fehlerbild), aber Chrome laeuft damit verlaesslicher.
RUN printf '#!/bin/sh\nexec /opt/google/chrome/chrome --no-sandbox --disable-dev-shm-usage "$@"\n' \
        > /usr/local/bin/chrome-ci \
    && chmod +x /usr/local/bin/chrome-ci

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Coverage-Treiber vorhanden, aber standardmaessig AUS (Performance).
#
# pcov ist absichtlich INSTALLIERT und nur abgeschaltet: Pests Test Impact Analysis
# braucht einen Coverage-Treiber, um den Abhaengigkeitsgraphen aufzunehmen, und ein
# Job kann ihn ueber diese INI-Datei einschalten:
#   printf 'pcov.enabled=1\n' > /etc/php/8.5/cli/conf.d/99-disable-pcov.ini
# Nicht per `php -d`: Paratest-Worker starten ohne die -d-Flags des Elternprozesses,
# und PHPUnits PcovRestarter verwirft sie beim Re-Exec.
#
# Vorher stand hier nur `pcov.enabled=0`, ohne dass pcov installiert war — die Zeile
# war also ein No-Op, und ein TIA-Lauf in diesem Image hat still einen leeren Graphen
# aufgezeichnet statt einen Fehler zu werfen.
RUN if [ -f /etc/php/${PHP_VERSION}/cli/conf.d/20-xdebug.ini ]; then \
      mv /etc/php/${PHP_VERSION}/cli/conf.d/20-xdebug.ini /etc/php/${PHP_VERSION}/cli/conf.d/20-xdebug.ini.disabled; \
    fi \
    && printf "pcov.enabled=0\n" > /etc/php/${PHP_VERSION}/cli/conf.d/99-disable-pcov.ini

WORKDIR /app
