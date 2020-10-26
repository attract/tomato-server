FROM attractgrouphub/alpine-php7-nginx-composer:1.17

MAINTAINER Amondar

ENV NODE_VERSION 10.16.0

RUN apk upgrade --no-cache -U \
    && apk --update add supervisor bash git openssl-dev g++ gcc libgcc  autoconf curl \
        file imagemagick imagemagick-dev libtool

RUN apk add --no-cache libstdc++ \
    && apk add --no-cache --virtual .build-deps \
        binutils-gold \
        curl \
        g++ \
        gcc \
        gnupg \
        libgcc \
        linux-headers \
        make \
        python2

RUN for key in \
        94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
        FD3A5288F042B6850C66B31F09FE44734EB7990E \
        71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
        DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
        C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
        B9AE9905FFD7803F25714661B63B535A4C206CA9 \
        77984A986EBC2AA786BC0F66B01FBB92821C587A \
        8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
        4ED778F539E3634C779C87C6D7062848A1AB005C \
        A48C2BEE680E841632CD4E44F07496B3EB3C1762 \
        B9E2F5981AA6E0CD28160D9FF13993A75599653C \
      ; do \
        gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
        gpg --batch --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
        gpg --batch --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
      done \
    && mkdir -m 777 /var/nodeinstall && cd /var/nodeinstall \
    && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.xz" \
    && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
    && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
    && grep " node-v$NODE_VERSION.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
    && tar -xf "node-v$NODE_VERSION.tar.xz" \
    && cd "node-v$NODE_VERSION" \
    && ./configure \
    && make -j$(getconf _NPROCESSORS_ONLN) V= \
    && make install \
    && cd .. \
    && rm -Rf "node-v$NODE_VERSION" \
    && rm "node-v$NODE_VERSION.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt

RUN pecl install imagick
RUN docker-php-ext-enable imagick

RUN npm install --global gulp && \
    npm install --global yarn && \
    composer global require hirak/prestissimo

# Install mongo
RUN pecl install mongodb
RUN echo "extension=mongodb.so" > /usr/local/etc/php/conf.d/mongodb.ini
RUN apk del --no-cache autoconf && apk del .build-deps

# Set environment variables to use them in PHP config files
ENV FPM_PM static
ENV FPM_PM_MAX_CHILDREN 4
ENV PHP_DATE_TIMEZONE Europe/Moscow
ENV PHP_MEMORY_LIMIT 500M
ENV PHP_POST_MAX_SIZE 512M
ENV PHP_UPLOAD_MAX_SIZE 512M
ENV PHP_SMTP localhost
ENV PHP_SMTP_PORT 25
ENV PHP_EXTRA_CONFIGURE_ARGS --enable-fpm --with-fpm-user=root --with-fpm-group=root
ENV COMPOSER_MEMORY_LIMIT -1


EXPOSE 80