FROM php:fpm-alpine
MAINTAINER Luis García <louisantoniogarcia@gmail.com>

# Install the PHP extensions that TYPO3 needs
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
	&& apk add --no-cache --virtual .typo3-phpexts-rundeps openssl \
    && apk del .build-deps

# Install required 3rd party tools
RUN set -xe \
    && apk add --no-cache imagemagick

# Install TYPO3 - first try
#ADD https://get.typo3.org/8 /var/www

# Install TYPO3
RUN set -xe \
    && cd /var/www/html \
    && wget -O - https://get.typo3.org/8 | tar -xzf - \
    && ln -s typo3_src-* typo3_src \
    && ln -s typo3_src/index.php \
    && ln -s typo3_src/typo3 \
    && mkdir typo3temp typo3conf fileadmin uploads \
    && touch FIRST_INSTALL \
    && chown www-data:www-data . typo3_src typo3 index.php typo3temp typo3conf fileadmin uploads FIRST_INSTALL

#RUN set -xe \
#    && chown www-data:www-data /var/www/html
