#//----------------------------------------------------------------------------
#// PHP7.3 FastCGI Server ( for KUSANAGI Runs on Docker Ver. PRESSMAN)
#//----------------------------------------------------------------------------
FROM php:7.3.11-fpm-alpine
LABEL maintainer="PRESSMAN <wp10@pressman.ne.jp>"

# Environment variable
ARG MYSQL_VERSION=10.3.18-r0
ARG APCU_VERSION=5.1.18
ARG APCU_BC_VERSION=1.0.5

RUN apk update && \
	apk add --update --no-cache --virtual .build-mozjpeg \
		nasm \
		musl-dev \
		make \
		libtool \
		pkgconf \
		gcc \
		automake \
		autoconf && \
	curl -LO https://github.com/mozilla/mozjpeg/archive/v3.3.1.tar.gz && \
	tar xf v3.3.1.tar.gz && \
	cd mozjpeg-3.3.1 && \
	autoreconf -fiv && ./configure && make && make install && \
	cd .. && \
	apk del .build-mozjpeg

RUN apk add --update --no-cache \
		libbz2 \
		gd \
		gettext \
		libmcrypt \
		libzip-dev \
		libxslt && \ 
	apk add --update --no-cache --virtual .build-php \
		$PHPIZE_DEPS \
		mariadb=$MYSQL_VERSION \
		mariadb-dev=$MYSQL_VERSION \
		gd-dev \
		jpeg-dev \
		libpng-dev \
		libwebp-dev \
		libxpm-dev \
		zlib-dev \
		freetype-dev \
		bzip2-dev \
		libexif-dev \
		xmlrpc-c-dev \
		pcre-dev \
		gettext-dev \
		libmcrypt-dev \
		libxslt-dev && \
	pecl install apcu-$APCU_VERSION && \
	docker-php-ext-enable apcu && \
	pecl install apcu_bc-$APCU_BC_VERSION && \
	docker-php-ext-enable apc && \
	rm /usr/lib/libjpeg.so* && \
	rm /usr/lib/libturbojpeg.so* && \
	ln -s /opt/mozjpeg/bin/* /usr/bin && \
	ln -s /opt/mozjpeg/lib64/*.so* /usr/lib && \
	docker-php-ext-configure gd --with-jpeg-dir=/opt/mozjpeg && \
	docker-php-ext-install \
		mysqli \
		opcache \
		gd \
		bz2 \
		pdo pdo_mysql \
		bcmath exif gettext pcntl \
		soap sockets sysvsem sysvshm xmlrpc xsl zip && \
	apk del .build-php && \
	rm -f /usr/local/etc/php/conf.d/docker-php-ext-apc.ini && \
	rm -f /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini && \
	rm -f /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini && \
	mkdir -p /etc/php.d/

COPY files/*.ini /usr/local/etc/php/conf.d/
COPY files/opcache*.blacklist /etc/php.d/
