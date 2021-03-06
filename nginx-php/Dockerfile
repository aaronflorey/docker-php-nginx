FROM php:7.4-fpm-alpine as base

# Setup extensions
RUN apk add --update --no-cache \
      freetype \
      libjpeg-turbo \
      libpng \
      freetype-dev \
      libjpeg-turbo-dev \
      libpng-dev \
      oniguruma-dev \
      libxml2-dev \
      curl-dev \
      zip libzip-dev \
      $PHPIZE_DEPS \
      nginx \
      supervisor \
      curl \
      autoconf \
      icu-dev \
      g++ \
      libtool \
      make \
      pcre-dev \
      jpegoptim \
      optipng \
      pngquant \
      vim \
      nano \
      busybox \
      gnu-libiconv \
      mysql-client \
    && docker-php-ext-configure gd \
      --with-freetype=/usr/include/ \
      --with-jpeg=/usr/include/ \
    && docker-php-ext-configure zip \
    && docker-php-ext-install -j$(nproc) intl gd pdo_mysql opcache mbstring xml curl zip exif pcntl sockets soap \
    && pecl install redis \
    && docker-php-ext-enable gd intl pdo_mysql opcache mbstring xml curl zip redis exif pcntl sockets soap \
    && apk del --no-cache \
      freetype-dev \
      libjpeg-turbo-dev \
      libpng-dev \
      oniguruma-dev \
      libxml2-dev \
      curl-dev \
      autoconf \
      g++ \
      libtool \
      make \
      pcre-dev \
      libmemcached-dev \
      $PHPIZE_DEPS \
    && rm -rf /tmp/* 

RUN curl http://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer

# Nginx
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/php-fpm.conf /usr/local/etc/php-fpm.d/www.conf
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY config/php.ini "$PHP_INI_DIR/conf.d/custom.ini"

# Configure supervisord
RUN mkdir -p /etc/supervisor/extras/
COPY config/supervisord.conf /etc/supervisor/supervisord.conf
COPY config/supervisor/nginx.conf /etc/supervisor/conf.d/nginx.conf
COPY config/supervisor/php.conf /etc/supervisor/conf.d/php.conf
COPY config/supervisor /etc/supervisor/extras

# configure cron
RUN echo "*       *       *       *       *       php /var/www/html/artisan schedule:run" > /var/spool/cron/crontabs/root

COPY config/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Setup document root
RUN mkdir -p /var/www/html && \
  chown -R nobody.nobody /var/www/html && \
  chown -R nobody.nobody /run && \
  chown -R nobody.nobody /var/lib/nginx && \
  chown -R nobody.nobody /var/log/nginx

# Add healthcheck
HEALTHCHECK --start-period=10s CMD curl --fail http://localhost || exit 1

# Add application
WORKDIR /var/www/html
#COPY --chown=nobody ./ /var/www/html/

# Expose the port nginx is reachable on
EXPOSE 80

ENV migrate=1

# Let supervisord start nginx & php-fpm
CMD ["sh","/entrypoint.sh"]

FROM base as mssql
RUN curl https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_17.5.1.1-1_amd64.apk -O \
    && curl https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_17.5.1.1-1_amd64.apk -O \
    && apk add --allow-untrusted msodbcsql17_17.5.1.1-1_amd64.apk \
    && apk add --allow-untrusted mssql-tools_17.5.1.1-1_amd64.apk \
    # at the mssql-tools binary to the path.
    && export PATH="$PATH:/opt/mssql-tools/bin" \
    && apk add --update --no-cache unixodbc-dev $PHPIZE_DEPS unixodbc freetds freetds-dev \
    && docker-php-ext-configure pdo_odbc --with-pdo-odbc=unixODBC,/usr  \
    && docker-php-ext-install pdo_odbc \
    && pecl install pdo_sqlsrv sqlsrv \
    && docker-php-ext-enable sqlsrv pdo_sqlsrv pdo_odbc \
    && apk del --no-cache $PHPIZE_DEPS freetds-dev unixodbc-dev \
    && rm -rf /tmp/* \
    && rm "$PHP_INI_DIR/conf.d/custom.ini"
