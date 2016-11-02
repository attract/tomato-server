FROM attractgrouphub/alpine-php5-composer-nginx

MAINTAINER Amondar

RUN apk upgrade --update && apk add supervisor nodejs bash php5-fpm php5-mysql php5-pdo_mysql \
php5-pdo_sqlite php5-mcrypt php5-ctype php5-xml php5-pcntl php5-exif php5-gd php5-zip && \
rm -rf /var/cache/apk/* && \
npm install --global gulp