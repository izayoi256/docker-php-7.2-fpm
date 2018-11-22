FROM php:7.2-fpm

ENV COMPOSER_ALLOW_SUPERUSER=1

RUN set -x \
    && sed -i.bak -e "s%http://deb.debian.org/debian%http://ftp.riken.jp/pub/Linux/debian/debian%g" /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        iproute \
        git \
        sudo \
        unzip \
        zlib1g-dev \
    && pecl install \
        apcu \
        xdebug \
    && docker-php-ext-install \
        zip \
    && docker-php-ext-enable \
        xdebug \
        apcu \
    && apt-get clean \
    && rm -rf /tmp/*

RUN curl -sS https://getcomposer.org/installer \
    | php -- \
        --filename=composer \
        --install-dir=/usr/local/bin \
    && mkdir /var/www/.composer \
    && chown www-data:www-data /var/www/.composer \
    && sudo -u www-data composer config -g repos.packagist composer https://packagist.jp \
    && sudo -u www-data composer global require --optimize-autoloader hirak/prestissimo

COPY ./entrypoint /usr/local/bin/

ENTRYPOINT ["entrypoint"]
CMD ["php-fpm"]
