FROM php:5.6-apache-stretch
LABEL maintainer="Yosep Nurawan <yosepnurawan.official@gmail.com>"

# Install php extension
RUN apt-get update -y -qq && \
    apt-get install -y -qq \
        curl \
        zlib1g-dev \
        libicu-dev \
        libaio-dev \
        libmcrypt-dev \
        g++ \
        git \
        libpng-dev \
        libjpeg62-turbo-dev \
        libfreetype6-dev \
        unzip \
        build-essential \
        libaio1 \
        && apt-get clean -y

# Configure extension php
RUN docker-php-ext-configure intl
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include --with-jpeg-dir=/usr/include
RUN docker-php-ext-install \
        intl \
        mysqli \
        pdo \
        pdo_mysql \
        mcrypt \
        gd

# Memcached for compatible PHP 5.6
RUN apt-get update -qq \
    && apt-get install -y -qq libmemcached-dev \
    && pecl install memcached-2.2.0 \
    && docker-php-ext-enable memcached

# SERTIFICATE
# ADD /conf/apache/bin/curl-ca-bundle.crt /usr/local/share/ca-certificates/foo.crt
# RUN update-ca-certificates#

# Apache configurations, mod rewrite
RUN ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load

# Install composer
RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
  && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
  && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }"

# Oracle instantclient
RUN curl -L -o /tmp/instantclient-sdk-12.2.zip http://bit.ly/2Bab3NM \
    && curl -L -o /tmp/instantclient-basic-12.2.zip http://bit.ly/2mBFHdA \
    && ln -s /usr/include/php5 /usr/include/php \
    && mkdir -p /opt/oracle/instantclient \
    && unzip -q /tmp/instantclient-basic-12.2.zip -d /opt/oracle \
    && mv /opt/oracle/instantclient_12_2 /opt/oracle/instantclient/lib \
    && unzip -q /tmp/instantclient-sdk-12.2.zip -d /opt/oracle \
    && mv /opt/oracle/instantclient_12_2/sdk/include /opt/oracle/instantclient/include \
    && ln -s /opt/oracle/instantclient/lib/libclntsh.so.12.1 /opt/oracle/instantclient/lib/libclntsh.so \
    && ln -s /opt/oracle/instantclient/lib/libocci.so.12.1 /opt/oracle/instantclient/lib/libocci.so \
    && echo /opt/oracle/instantclient/lib >> /etc/ld.so.conf \
    && ldconfig

RUN echo 'instantclient,/opt/oracle/instantclient/lib' | pecl install oci8-2.0.12

# Install pdo_oci with pecl
RUN pecl channel-update pear.php.net \
    && cd /tmp \
    && pecl download pdo_oci \
    && tar xvf /tmp/PDO_OCI-1.0.tgz -C /tmp \
    && sed 's/function_entry/zend_function_entry/' -i /tmp/PDO_OCI-1.0/pdo_oci.c \
    && sed 's/10.1/12.1/' -i /tmp/PDO_OCI-1.0/config.m4 \
    && cd /tmp/PDO_OCI-1.0 \
    && phpize \
    && ./configure --with-pdo-oci=/opt/oracle/instantclient \
    && make install

RUN a2enmod rewrite

ADD . /var/www/html
EXPOSE 80
