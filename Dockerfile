FROM parana/jessie-lamp
#
# Esta imagem herda de parana/jessie-lamp que já possui toda a Stack LAMP
# e um Servidor SSH. A imagem parana/jessie-lamp habilita o módulo
# mod_rewrite que permite usar as regras RewriteRule do Apache. Além disso ela
# herda de php:5.6-apache que usa a versão 8 do Debian de codinome Jessie
#
MAINTAINER João Antonio Ferreira "joao.parana@gmail.com"

ENV REFRESHED_AT 2015-10-23

# WORKDIR /var/www/html

# Here are where the files are installed on the system:
#    All configuration files (like my.cnf) are under /etc
#    All binaries, libraries, headers, etc., are under /usr
#    The data directory is under /var

# Usaremos uma shell específica no Entrypoint sobreescrevendo a herdada
COPY ./docker-entrypoint.sh /
RUN chmod a+rx /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
EXPOSE 80
EXPOSE 22

COPY ./start-wordpress /start-wordpress

# Flag Default fornecida via comando CMD
CMD ["--help"]
