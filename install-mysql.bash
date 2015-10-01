#!/bin/bash

set -e

echo "••• `date` - Iniciando a Instalação do MySQL Versão $MYSQL_VERSION •••"

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
groupadd -r mysql && useradd -r -g mysql mysql

mkdir /docker-entrypoint-initdb.d

# FATAL ERROR: please install the following Perl modules before executing /usr/local/mysql/scripts/mysql_install_db:
# File::Basename
# File::Copy
# Sys::Hostname
# Data::Dumper
apt-get update && apt-get install -y perl --no-install-recommends && rm -rf /var/lib/apt/lists/*

# gpg: key 5072E1F5: public key "MySQL Release Engineering <mysql-build@oss.oracle.com>" imported
apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys A4A9406876FCBD3C456770C88C718D3B5072E1F5

echo "deb http://repo.mysql.com/apt/debian/ jessie mysql-${MYSQL_MAJOR}" > /etc/apt/sources.list.d/mysql.list

# the "/var/lib/mysql" stuff here is because the mysql-server postinst doesn't have an explicit way to disable the mysql_install_db codepath besides having a database already "configured" (ie, stuff in /var/lib/mysql/mysql)
# also, we set debconf keys to make APT a little quieter
{ echo mysql-community-server mysql-community-server/data-dir select ''; \
  echo mysql-community-server mysql-community-server/root-pass password ''; \
  echo mysql-community-server mysql-community-server/re-root-pass password ''; \
  echo mysql-community-server mysql-community-server/remove-test-db select false; \
} | debconf-set-selections \
  && apt-get update && apt-get install -y mysql-server="${MYSQL_VERSION}"* && rm -rf /var/lib/apt/lists/* \
  && rm -rf /var/lib/mysql && mkdir -p /var/lib/mysql

echo "••• `date` - Exibindo o conteudo original do arquivo /etc/mysql/my.cnf"
cat /etc/mysql/my.cnf

# comment out a few problematic configuration values
# don't reverse lookup hostnames, they are usually another container
sed -Ei 's/^(bind-address|log)/#&/' /etc/mysql/my.cnf \
  && echo 'skip-name-resolve' | awk '{ print } $1 == "[mysqld]" && c == 0 { c = 1; system("cat") }' /etc/mysql/my.cnf > /tmp/my.cnf \
  && mv /tmp/my.cnf /etc/mysql/my.cnf
echo 'skip-host-cache' | awk '{ print } $1 == "[mysqld]" && c == 0 { c = 1; system("cat") }' /etc/mysql/my.cnf > /tmp/my.cnf \
  && mv /tmp/my.cnf /etc/mysql/my.cnf

echo "••• `date` - Exibindo o conteudo modificado do arquivo /etc/mysql/my.cnf"
cat /etc/mysql/my.cnf

echo "••• "
echo "••• `date` - Servidor MySQL instalado  "
echo "••• "
