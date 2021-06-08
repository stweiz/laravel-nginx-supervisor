FROM php:8.0-fpm-alpine

LABEL maintainer="stef.weiz@googlemail.com"

WORKDIR /var/www/app
ENTRYPOINT ["./docker/entrypoint.sh"]

ENV NGINX_VERSION 1.20.0
ENV NJS_VERSION 0.5.3
ENV PKG_RELEASE 1

COPY --from=composer:2.0 /usr/bin/composer /usr/local/bin/composer
COPY docker/ docker/

RUN set -x && \
    apk add --no-cache curl ca-certificates supervisor \
    libjpeg-turbo libjpeg-turbo-dev libpng libpng-dev libzip-dev freetype freetype-dev zip && \
    nginxPackages=" \
    nginx=${NGINX_VERSION}-r${PKG_RELEASE} \
    nginx-module-xslt=${NGINX_VERSION}-r${PKG_RELEASE} \
    nginx-module-geoip=${NGINX_VERSION}-r${PKG_RELEASE} \
    nginx-module-image-filter=${NGINX_VERSION}-r${PKG_RELEASE} \
    nginx-module-njs=${NGINX_VERSION}.${NJS_VERSION}-r${PKG_RELEASE}" && \
    KEY_SHA512="e7fa8303923d9b95db37a77ad46c68fd4755ff935d0a534d26eba83de193c76166c68bfe7f65471bf8881004ef4aa6df3e34689c305662750c0172fca5d8552a *stdin" && \
    apk add --no-cache --virtual .cert-deps openssl && \
    wget -O /tmp/nginx_signing.rsa.pub https://nginx.org/keys/nginx_signing.rsa.pub && \
    if [ "$(openssl rsa -pubin -in /tmp/nginx_signing.rsa.pub -text -noout | openssl sha512 -r)" = "$KEY_SHA512" ]; then \
        echo "key verification succeeded!"; \
        mv /tmp/nginx_signing.rsa.pub /etc/apk/keys/; \
    else \
        echo "key verification failed!"; \
        exit 1; \
    fi && \
    apk del .cert-deps && \
    apk add -X "https://nginx.org/packages/alpine/v$(egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release)/main" --no-cache $nginxPackages && \
    rm /etc/nginx/conf.d/default.conf && \
    mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" && \
    cp docker/nginx/app.conf /etc/nginx/conf.d && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install gd pcntl pdo pdo_mysql zip && \
    apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev
