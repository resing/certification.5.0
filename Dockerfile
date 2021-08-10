FROM php:7.4-apache
LABEL maintainer="dev@chialab.io"

# Download script to install PHP extensions and dependencies
ADD https://raw.githubusercontent.com/mlocati/docker-php-extension-installer/master/install-php-extensions /usr/local/bin/

RUN chmod uga+x /usr/local/bin/install-php-extensions && sync

RUN DEBIAN_FRONTEND=noninteractive apt-get update -q \
    && DEBIAN_FRONTEND=noninteractive apt-get install -qq -y \
      curl \
      git \
      zip unzip \
    && install-php-extensions \
      bcmath \
      bz2 \
      calendar \
      exif \
      gd \
      intl \
      ldap \
      memcached \
      mysqli \
      opcache \
      pdo_mysql \
      pdo_pgsql \
      pgsql \
      redis \
      soap \
      xsl \
      zip \
      sockets \
      pdo_sqlsrv \
      sqlsrv \
# already installed:
#      iconv \
#      mbstring \
    && a2enmod rewrite

# Install Composer.
ENV PATH=$PATH:/root/composer2/vendor/bin:/root/composer1/vendor/bin \
  COMPOSER_ALLOW_SUPERUSER=1 \
  COMPOSER_HOME=/root/composer2 \
  COMPOSER1_HOME=/root/composer1
RUN cd /opt \
  # Download installer and check for its integrity.
  && curl -sSL https://getcomposer.org/installer > composer-setup.php \
  && curl -sSL https://composer.github.io/installer.sha384sum > composer-setup.sha384sum \
  && sha384sum --check composer-setup.sha384sum \
  # Install Composer 2 and expose `composer` as a symlink to it.
  && php composer-setup.php --install-dir=/usr/local/bin --filename=composer2 --2 \
  && ln -s /usr/local/bin/composer2 /usr/local/bin/composer \
  # Install Composer 1, make it point to a different `$COMPOSER_HOME` directory than Composer 2, install `hirak/prestissimo` plugin.
  && php composer-setup.php --install-dir=/usr/local/bin --filename=.composer1 --1 \
  && printf "#!/bin/sh\nCOMPOSER_HOME=\$COMPOSER1_HOME\nexec /usr/local/bin/.composer1 \$@" > /usr/local/bin/composer1 \
  && chmod 755 /usr/local/bin/composer1 \
  && composer1 global require hirak/prestissimo \
  # Remove installer files.
  && rm /opt/composer-setup.php /opt/composer-setup.sha384sum \
  && curl -sS https://get.symfony.com/cli/installer | bash && mv /root/.symfony/bin/symfony /usr/local/bin/symfony
RUN docker-php-ext-install mysqli
RUN pecl install xdebug-2.8.0
RUN docker-php-ext-enable xdebug
RUN echo "xdebug.remote_enable=1" >> /usr/local/etc/php/php.ini
RUN echo "xdebug.show_error_trace=1"  >> /usr/local/etc/php/php.ini \
    && echo "xdebug.idekey=PHPStorm"  >> /usr/local/etc/php/php.ini \
    && echo "xdebug.remote_enable=1"  >> /usr/local/etc/php/php.ini \
    && echo "xdebug.remote_host=172.17.0.1"  >> /usr/local/etc/php/php.ini \
    && echo "xdebug.remote_handler=dbgp"  >> /usr/local/etc/php/php.ini \
    && echo "xdebug.remote_connect_back=Off" >> /usr/local/etc/php/php.ini \
    && echo "xdebug.remote_autostart =0" >> /usr/local/etc/php/php.ini \
    && echo "xdebug.remote_port =9000" >> /usr/local/etc/php/php.ini

RUN composer global require "squizlabs/php_codesniffer=*"

RUN curl -L https://cs.symfony.com/download/php-cs-fixer-v2.phar -o php-cs-fixer
RUN chmod 775 php-cs-fixer
RUN mv php-cs-fixer /usr/local/bin/php-cs-fixer

RUN curl -L https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar -o phpcs
RUN chmod 775 phpcs
RUN mv phpcs /usr/local/bin/phpcs

RUN composer require phpmd/phpmd
RUN apt-get -y update
RUN apt-get -y install git
RUN git config --global user.email "USER@DOMAIN.COM" && git config --global user.name "USERNAME"



