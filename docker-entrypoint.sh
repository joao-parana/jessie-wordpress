#!/bin/bash
set -e

echo ". . . . Contêiner JessieLAMP . . . ."
echo "Você invocou com os seguintes parâmetros: $@"
if [ "$1" = 'modules' ]; then
    echo "Veja abaixo a lista de Módulos PHP instalados"
    find /usr/src/php/ext -mindepth 2 -maxdepth 2 -type f -name 'config.m4' | cut -d/ -f6 | sort
    exit 0
fi

if [ "$1" = 'start-apache' ]; then
    echo "Iniciando Apache Web Server"
    /start-apache
    exit 0
fi

if [ "$1" = 'start-apache-and-mysql' ]; then
    echo "Iniciando Apache e MySQL"
    /start-apache-and-mysql
    exit 0
fi

if [ "$1" = 'start-all' ]; then
    echo "Iniciando Apache e MySQL"
    /start-all
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
    echo "docker run --rm -i-t NOME-IMAGEM start-apache"
    echo "       Para iniciar apenas o Apache WEB Server"
    echo "docker run --rm -i-t NOME-IMAGEM start-apache-and-mysql"
    echo "       Para iniciar o Apache WEB Server e o MySQL Server"
    echo "docker run --rm -i-t NOME-IMAGEM start-all"
    echo "       Para iniciar o Apache WEB Server, o MySQL Server e o Servidor SSH"
    echo "docker run --rm -i-t NOME-IMAGEM /bin/bash"
    echo "       Para iniciar apenas uma shell bash - isto serve para investigar problemas"
    echo " "
    echo "Observação:"
    echo "  Você poderá substituir as opções '--rm -i-t' pela opção '-d' "
    echo "  Isso fará com que o conteiner rode como Daemon. "
    echo "  Mas isso só faz sentido para o caso das opções  "
    echo "  • start-apache"
    echo "  • start-apache-and-mysql"
    echo "  • start-all"
    echo " "
    exit 0
fi

echo ". . . . . . . . . . . . . . . . . . ."
exec "$@"
