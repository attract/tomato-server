FROM attractgrouphub/alpine-php7-nginx-composer:1.0

MAINTAINER Amondar

RUN apk --update add supervisor nodejs bash git openssl-dev g++ autoconf make curl
RUN npm install --global gulp && \
    npm install --global yarn && \
    composer global require "hirak/prestissimo:^0.3"

# Install mongo
RUN pecl install mongodbgulp
RUN echo "extension=mongodb.so" > /usr/local/etc/php/conf.d/mongodb.ini
RUN apk del --no-cache autoconf