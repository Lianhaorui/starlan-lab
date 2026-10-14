FROM php:7.4-apache-bullseye

# bullseye LTS 已于 2026-08-31 结束，常规镜像源索引漂移导致 404。
# 改用 snapshot.debian.org 的日期快照，永久冻结 bullseye 软件包版本。
# 快照的 Release 文件会"过期"，因此必须关闭 Check-Valid-Until。
# 参考：https://github.com/activepieces/activepieces/commit/86b9c29
RUN printf 'deb http://snapshot.debian.org/archive/debian/20260825T000000Z bullseye main\ndeb http://snapshot.debian.org/archive/debian-security/20260825T000000Z bullseye-security main\n' > /etc/apt/sources.list \
    && echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99snapshot \
    && apt-get update -qq \
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