#!/bin/bash

set -e

# Informações abaixo estão Hard-coded
# apenas por motivos didáticos
MYSQL_ROOT_PASSWORD=xpto
MYSQL_DATABASE=my-db
MYSQL_USER=wp
MYSQL_PASSWORD=secret

# A abordagem correta é obter parâmetros
# como no exemplo abaixo
SITE_STAGE="$STAGE"
if [ -z "$SITE_STAGE" ]; then
    SITE_STAGE='DEVELOPMENT'
fi

echo "••• `date` - Iniciando o Contêiner para o MySQL •••"
echo "••• `date` - Diretório Corrente : `pwd` "
echo "••• `date` - Conteúdo de /var/lib/mysql  "
ls -la /var/lib/mysql
# set -x

# Execute cat /etc/mysql/my.cnf |  grep datadir | awk '$1 == "datadir" { print $3; exit }'

DATABASE_CONFIGURED=false
DATADIR=/var/lib/mysql
echo "••• `date` - DATADIR : $DATADIR "
if [ -d "$DATADIR/mysql" ]; then
    echo "••• `date` - Default database already exists on $DATADIR/mysql"
    DATABASE_CONFIGURED=true
fi
tempSqlFile='/tmp/mysql-init-file.sql'
cat > "$tempSqlFile" <<-EOFSQL
    DROP DATABASE IF EXISTS test ;
EOFSQL

if [ ! -d "$DATADIR/mysql" ]; then
    echo "••• `date` - First time I need install default database ..."
    tempSqlFile='/tmp/mysql-first-time-only.sql'
    if [ -z "$MYSQL_ROOT_PASSWORD" -a -z "$MYSQL_ALLOW_EMPTY_PASSWORD" ]; then
        echo >&2 'error: database is uninitialized and MYSQL_ROOT_PASSWORD not set'
        echo >&2 '  Did you forget to add -e MYSQL_ROOT_PASSWORD=... ?'
        exit 1
    fi

    echo "••• `date` - Running mysql_install_db ..."
    mysql_install_db --datadir="$DATADIR"
    echo "••• `date` - Finished mysql_install_db"

    # Comandos SQL devem ficar em linhas individuais
    # terminadas por ponto-e-virgula sem quebras de linha

    cat > "$tempSqlFile" <<-EOSQL
    -- What's done in this file shouldn't be replicated
    --  or products like mysql-fabric won't work
    SET @@SESSION.SQL_LOG_BIN=0;

    DELETE FROM mysql.user ;
    CREATE USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' ;
    GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;
    DROP DATABASE IF EXISTS test ;
EOSQL

    if [ "$MYSQL_DATABASE" ]; then
        echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` ;" >> "$tempSqlFile"
    fi

    if [ "$MYSQL_USER" -a "$MYSQL_PASSWORD" ]; then
        echo "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD' ;" >> "$tempSqlFile"

        if [ "$MYSQL_DATABASE" ]; then
            echo "GRANT ALL ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%' ;" >> "$tempSqlFile"
        fi
    fi

    echo 'FLUSH PRIVILEGES ;' >> "$tempSqlFile"

    echo "USE  \`$MYSQL_DATABASE\` ;" >> "$tempSqlFile"
    echo "--" >> "$tempSqlFile"
    echo "-- Para testar Ajax com PHP Orientado a Objetos" >> "$tempSqlFile"
    echo "--" >> "$tempSqlFile"
    echo "CREATE TABLE IF NOT EXISTS CRUDClass (" >> "$tempSqlFile"
    echo "  id int(11) NOT NULL AUTO_INCREMENT," >> "$tempSqlFile"
    echo "  name varchar(255) NOT NULL," >> "$tempSqlFile"
    echo "  email varchar(255) NOT NULL," >> "$tempSqlFile"
    echo "  PRIMARY KEY (id)" >> "$tempSqlFile"
    echo ");" >> "$tempSqlFile"
    echo " " >> "$tempSqlFile"
    echo "INSERT INTO CRUDClass VALUES(NULL,'João','name1@email.com');" >> "$tempSqlFile"
    echo "INSERT INTO CRUDClass VALUES(NULL,'Pedro','name2@email.com');" >> "$tempSqlFile"
    echo "INSERT INTO CRUDClass VALUES(NULL,'Maria','name3@email.com');" >> "$tempSqlFile"
    echo "COMMIT;" >> "$tempSqlFile"

    # mysql -u root -p$MYSQL_ROOT_PASSWORD -h 127.0.0.1 < "$tempSqlFile"
fi

chown -R mysql:mysql "$DATADIR"

echo "••• `date` -----------------------------------------"
ip addr

echo "••• `date` - Executando mysqld --init-file=$tempSqlFile"
cat "$tempSqlFile"
echo "••• `date` - -----------------------------------------"
mysqld --init-file="$tempSqlFile"  & # Start the Deamon

echo "••• `date` - Sleeping 10 seconds -"
sleep 10

if [ "$DATABASE_CONFIGURED" = true ]; then
    echo "••• `date` - default database already installed and configured  ..."
fi

echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = "
echo "••• `date` - Endereços IP  "
ip addr
echo "••• `date` - Conteúdo de /etc/hosts  "
cat /etc/hosts
echo "••• `date` - Conteúdo de /var  "
ls -la /var

echo "DATADIR/mysql = $DATADIR/mysql"
echo "••• `date` - Conteúdo de /var/lib/mysql  "
ls -la /var/lib/mysql
echo "••• "
echo "••• `date` - Servidor MySQL ativo e pronto pra uso  "
echo "••• "
