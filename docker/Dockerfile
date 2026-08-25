FROM php:7.4-apache-bullseye

# 国内网络默认走阿里源;海外构建:docker compose build --build-arg USE_CN_MIRROR=0
ARG USE_CN_MIRROR=1
RUN if [ "$USE_CN_MIRROR" = "1" ]; then \
      if [ -f /etc/apt/sources.list.d/debian.sources ]; then \
        sed -i 's|deb.debian.org/debian|mirrors.aliyun.com/debian|g; s|security.debian.org/debian-security|mirrors.aliyun.com/debian-security|g' /etc/apt/sources.list.d/debian.sources; \
      fi; \
      if [ -f /etc/apt/sources.list ] && [ -s /etc/apt/sources.list ]; then \
        sed -i 's|deb.debian.org|mirrors.aliyun.com|g; s|security.debian.org|mirrors.aliyun.com|g' /etc/apt/sources.list; \
      fi; \
    fi; \
    apt-get -o Acquire::Check-Valid-Until=false update -qq \
    && apt-get install -y -qq --no-install-recommends unzip zip \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pdo_mysql mysqli

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1 COMPOSER_NO_INTERACTION=1

WORKDIR /opt
RUN composer config --global allow-plugins.topthink/think-installer true \
    && composer create-project laravel/laravel:^7.0 portal --prefer-dist --quiet --no-security-blocking \
    && composer create-project topthink/think:5.0.22 admin --prefer-dist --quiet --no-security-blocking \
    && composer -d admin require topthink/framework:5.0.22 --no-security-blocking --quiet

RUN curl --retry 5 --retry-delay 3 --retry-all-errors -fsSL https://wordpress.org/latest.tar.gz | tar -xz -C /opt \
    && mv /opt/wordpress /opt/news

COPY docker/wp-cli.phar /usr/local/bin/wp
RUN chmod +x /usr/local/bin/wp

COPY docker/apache/ports.conf /etc/apache2/ports.conf
COPY docker/apache/portal.conf /etc/apache2/sites-available/portal.conf
COPY docker/apache/admin.conf /etc/apache2/sites-available/admin.conf
COPY docker/apache/news.conf /etc/apache2/sites-available/news.conf
RUN a2enmod rewrite \
    && a2dissite 000-default \
    && a2ensite portal admin news

COPY apps/portal/ /opt/portal/
COPY apps/admin/ /opt/admin/
COPY apps/news-plugin/starlan-member /opt/news/wp-content/plugins/starlan-member

# TP5.0 core uses curly-brace string offsets (deprecated on PHP 7.4) and its
# bootstrap forces error_reporting(E_ALL), turning that into a fatal 500.
RUN sed -i 's/error_reporting(E_ALL);/error_reporting(E_ALL \& ~E_DEPRECATED \& ~E_NOTICE \& ~E_STRICT);/' /opt/admin/thinkphp/library/think/Error.php

RUN mkdir -p /opt/admin/runtime /opt/news/wp-content/uploads \
    && chown -R www-data:www-data /opt/portal/storage /opt/portal/bootstrap/cache \
       /opt/admin/runtime /opt/admin/application /opt/news/wp-content

COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80 81 82
ENTRYPOINT ["/entrypoint.sh"]
