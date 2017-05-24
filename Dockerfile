FROM php:7.1.5-apache
LABEL maintainer Sergey Kochetkov <legatdestr@gmail.com>
ENV KSB_WEB_TABLO_VERSION 0.0.1

RUN mkdir -p '/var/www/vhosts/er.em70.ru/' && \
    mkdir -p '/var/www/libs/frameworks/yii1' && \
    mkdir -p '/var/www/libs/web_tablo' && \
    mkdir -p '/var/www/vhosts/er.em70.ru/logs/' && \
    mkdir -p '/var/www/vhosts/er.em70.ru/.ht_temp/' && \
    mkdir -p '/var/www/vhosts/er.em70.ru/htdocs/' && \
    mkdir -p '/var/www/vhosts/er.em70.ru/protected/' && \
    rm -rf /var/www/html


COPY configs/custom.php.ini /usr/local/etc/php/custom.php.ini
COPY configs/sites-enabled/  /etc/apache2/sites-enabled/
COPY tmp/yii1 /var/www/libs/frameworks/yii1

RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        #postgresql \
        libpq-dev \
    && docker-php-ext-install -j$(nproc) iconv mcrypt iconv json mbstring pdo pdo_pgsql pgsql \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

# enable mod_rewrite
RUN ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load

WORKDIR /var/www/vhosts/er.em70.ru

EXPOSE 80

# Define default command.
CMD ["apache2-foreground"]