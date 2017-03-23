FROM php:fpm-alpine
MAINTAINER Luis García <louisantoniogarcia@gmail.com>

# install the PHP extensions we need
RUN set -xe \
    && apk add --no-cache --virtual .build-deps \
        freetype-dev \
		libjpeg-turbo-dev \
		libpng-dev \
		libxml2-dev \
		zlib-dev \
	\
	&& docker-php-ext-configure gd --with-freetype-dir=/usr --with-png-dir=/usr --with-jpeg-dir=/usr \
	&& docker-php-ext-install gd mysqli opcache soap zip \
	\
	&& runDeps="$( \
		scanelf --needed --nobanner --recursive \
			/usr/local/lib/php/extensions \
			| awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
			| sort -u \
			| xargs -r apk info --installed \
			| sort -u \
	)" \
	&& apk add --virtual .typo3-phpexts-rundeps $runDeps \
    && apk del .build-deps

RUN set -xe \
    && apk add --no-cache --virtual .typo3-runtime-deps \
        openssl \
        imagemagick
