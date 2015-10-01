#!/bin/bash

ROOT_PASS=$1

PASS=${ROOT_PASS:-$(pwgen -s 12 1)}
_word=$( [ ${ROOT_PASS} ] && echo "definida" || echo "randômica" )
echo "=> Usando a senha ${_word} para o usuário root"
echo "root:$PASS" | chpasswd

echo "=> Senha de root definida !"
touch /.root_pw_set

echo "========================================================================"
echo "Você pode conectar a este Contêiner Debian via SSH usando:"
echo ""
echo "    ssh -p <port> root@<host>"
echo ""
echo "Quando solicitado, informe a senha de root : '$PASS'"
echo ""
echo "Lembre de mudar a senha assim que possivel"
echo "========================================================================"
