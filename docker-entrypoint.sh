#!/bin/bash
set -e

#
# No ENTRYPOINT primeiro instalo o WP CLI (se ainda não existir) e depois
# executo a opção escolhida pelo usuário que pode ser uma das opções abaixo:
# '--help' (opção padrão)
# '/bin/bash' (para investigação e debug do contêiner)
# 'start-wordpress' (workflow normal de desenvolvimento)
#
# e-mail do user admin do Wordpress
if [ -z "$WP_EMAIL_ADDR" ]; then
    WP_EMAIL_ADDR='joao.parana@icloud.com'
fi
echo "••• `date` - WP_EMAIL_ADDR : $WP_EMAIL_ADDR "

WP_INSTALLED=false
WP_CLI_DIR=/usr/local/bin
WP_CLI_BINARY="$WP_CLI_DIR/wp"

set_config() {
  key="$1"
  value="$2"
  php_escaped_value="$(php -r 'var_export($argv[1]);' "$value")"
  sed_escaped_value="$(echo "$php_escaped_value" | sed 's/[\/&]/\\&/g')"
  sed -ri "s/((['\"])$key\2\s*,\s*)(['\"]).*\3/\1$sed_escaped_value/" wp-config.php
}

echo "••• `date` - WP_CLI_DIR : $WP_CLI_DIR | WP_CLI_BINARY : $WP_CLI_BINARY"
if [ -f "$WP_CLI_BINARY" ]; then
  echo "••• `date` - WP_CLI já está instalado em $WP_CLI_DIR"
  WP_INSTALLED=true
else
  echo "••• `date` - Instalando WP_CLI no diretório $WP_CLI_DIR"
  curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
  chmod a+rx wp-cli.phar && \
  mkdir -p "$WP_CLI_DIR"  && \
  mv wp-cli.phar "$WP_CLI_BINARY" && \
  wp --allow-root --info
  ls -lat /var/www/html
  /run-mysql.bash
  ls -lat /var/www/html
  if [ -d "/var/www/html/wp-content" ]; then
    echo "••• `date` - Wordpress já está instalado em /var/www/html"
  else
    echo "••• `date` - Fazendo o Download do Wordpress via WP_CLI"
    wp --allow-root  core download
    sleep 5
    echo "••• `date` - Criando wp-config.php para o Wordpress via WP_CLI"
    wp --allow-root core config --dbhost="127.0.0.1" \
            --dbname="my-db" --dbuser="wp" --dbpass="secret"
    # Aqui o wp-config.php já foi criado, porém localhost gera erro.
    # Precisamos usar 127.0.0.1 em vez de localhost.
    # set_config 'DB_HOST' "127.0.0.1"

    echo "••• `date` - Instalando o Wordpress via WP_CLI"
    wp core install --allow-root --url="dockerhost.local" \
            --title="Título do SITE" \
            --admin_user="admin" \
            --admin_password="minhasenha" \
            --admin_email="$WP_EMAIL_ADDR"
    cat /var/www/html/wp-config.php
  fi
fi

echo "••• `date` - Executável do WP_CLI"
ls -lat "$WP_CLI_BINARY"
echo "••• `date` - PHP_MEMORY_LIMIT = $PHP_MEMORY_LIMIT"

echo ". . . . Contêiner JessieWordpress . . . ."
echo "Você invocou com os seguintes parâmetros: $@"
if [ "$1" = 'modules' ]; then
    echo "Veja abaixo a lista de Módulos PHP instalados"
    find /usr/src/php/ext -mindepth 2 -maxdepth 2 -type f -name 'config.m4' | cut -d/ -f6 | sort
    exit 0
fi

if [ "$1" = '/bin/bash' ]; then
    echo "••• `date` - Iniciando Bash shell"
    /bin/bash
    exit 0
fi

if [ "$1" = 'start-wordpress' ]; then
    echo "••• `date` - Iniciando Apache, MySQL, servidor SSH e o Wordpress"
    /start-wordpress
    exit 0
fi

if [ "$1" = '--help' ]; then
    echo " "
    echo " "
    echo "Você pode invocar este Contêiner em 6 modos diferentes:"
    echo " "
    echo "docker run --rm -i-t NOME-IMAGEM --help"
    echo "       Para ver esta mensagem"
    echo "docker run --rm -i-t NOME-IMAGEM modules"
    echo "       Para ver a lista de módulos PHP disponíveis em runtime"
    echo "docker run --rm -i-t NOME-IMAGEM start-wordpress"
    echo "       Para iniciar o Apache WEB Server, o MySQL Server, o servidor SSH e o Wordpress"
    echo "docker run --rm -i-t NOME-IMAGEM /bin/bash"
    echo "       Para iniciar apenas uma shell bash - isto serve para investigar problemas"
    echo " "
    echo "Observação:"
    echo "  Você poderá substituir as opções '--rm -i-t' pela opção '-d' "
    echo "  Isso fará com que o conteiner rode como Daemon. "
    echo "  Mas isso só faz sentido para o caso da opção  "
    echo "  • start-wordpress"
    echo " "
    exit 0
fi

echo ". . . . . . . . . . . . . . . . . . ."
