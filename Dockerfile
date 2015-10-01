FROM php:5.6-apache
#
# php:5.6-apache usa a versão 8 do Debian de codinome Jessie
#
MAINTAINER João Antonio Ferreira "joao.parana@gmail.com"

# Habilitando o módulo mod_rewrite que permite usar
# as regras RewriteRule do Apache
RUN a2enmod rewrite

# instalando as extensões PHP que precisaremos
RUN apt-get update \
  && apt-get install -y libpng12-dev libjpeg-dev \
  && rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
	&& docker-php-ext-install gd

# instalando a extensão PHP para acesso a MySQL
RUN docker-php-ext-install mysqli

# Existem instruções neste link abaixo mas optei por fazer a instalação
# como na imagem oficial do Docker, com algumas poucas modificações.
# http://dev.mysql.com/doc/refman/5.6/en/linux-installation-debian.html

RUN mkdir /tmp/install-mysql
WORKDIR /tmp/install-mysql

ENV MYSQL_MAJOR 5.6
ENV MYSQL_VERSION 5.6.26

COPY install-mysql.bash ./
RUN ./install-mysql.bash

# Adicionando Suporte ao SSH com OpenSSH
ADD set_root_pw.sh /set_root_pw.sh
# Install packages
RUN apt-get update && \
    apt-get -y install openssh-server pwgen && \
    mkdir -p /var/run/sshd && \
    sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && \
    sed -i "s/PermitRootLogin without-password/PermitRootLogin yes/g" /etc/ssh/sshd_config

ENV AUTHORIZED_KEYS **None**

ENV PHP_MEMORY_LIMIT 119M
COPY config/php.ini /usr/local/etc/php/
RUN mkdir -p /var/log/php/ && chmod 777 /var/log/php/

VOLUME /var/www/html

WORKDIR /var/www/html

# Here are where the files are installed on the system:
#    All configuration files (like my.cnf) are under /etc
#    All binaries, libraries, headers, etc., are under /usr
#    The data directory is under /var

# Usaremos uma shell específica no Entrypoint
COPY ./docker-entrypoint.sh /
RUN chmod a+rx /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
EXPOSE 80

COPY ./start-apache /start-apache
COPY ./run-mysql.bash /run-mysql.bash
COPY ./start-apache-and-mysql /start-apache-and-mysql
COPY ./start-all /start-all

# Flag Default fornecida via comando CMD
CMD ["--help"]

# Módulos PHP instalados em instalações típicas:
#
# find /usr/src/php/ext -mindepth 2 -maxdepth 2 -type f \
#      -name 'config.m4' | cut -d/ -f6 | sort
#
# bcmath, bz2, calendar, ctype, curl, dba, dom, enchant, exif, fileinfo,
# filter, ftp, gd, gettext, gmp, hash, iconv, imap, interbase, intl, json,
# ldap, mbstring, mcrypt, mssql, mysql, mysqli, oci8, odbc, opcache, pcntl,
# pdo, pdo_dblib, pdo_firebird, pdo_mysql, pdo_oci, pdo_odbc, pdo_pgsql,
# pdo_sqlite, pgsql, phar, posix, pspell, readline, recode, reflection,
# session, shmop, simplexml, snmp, soap, sockets, spl, standard, sybase_ct,
# sysvmsg, sysvsem, sysvshm, tidy, tokenizer, wddx, xml, xmlreader, xmlrpc,
# xmlwriter, xsl, zip
#
