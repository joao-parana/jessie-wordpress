# jessie-lamp

> Imagem Docker para **Stack LAMP** usando Debian Jessie (version 8),
> Apache WebServer, o MySQL 5.6.26, o PHP versão 5.6 (A versão 7 ainda 
> não foi liberada) e o Wordpress

Este projeto foi testado com a **versão 1.8.2** do Docker

Usado no curso [http://joao-parana.com.br/blog/curso-docker/](http://joao-parana.com.br/blog/curso-docker/) criado para a Escola Linux.

Veja no Diagrama abaixo o contêiner, o Volume, e as portas do Apache e do SSH

![https://raw.githubusercontent.com/joao-parana/jessie-lamp/master/docs/img/jessie-lamp.png](https://raw.githubusercontent.com/joao-parana/jessie-lamp/master/docs/img/jessie-lamp.png)

Criando a imagem

    docker build -t HUB-USER-NAME/jessie-wordpress  .

Substitua o token `HUB-USER-NAME` pelo seu login em [http://hub.docker.com](http://hub.docker.com)


Usaremos aqui o nome `web_wp` para o Contêiner.
Caso exista algum conteiner com o mesmo nome rodando, 
podemos pará-lo assim:

    docker stop web_wp

> Pode demorar alguns segundos para parar e isto é normal.

Em seguida podemos removê-lo

    docker rm web_wp

Podemos executar o Contêiner iterativamente para obter um help assim:

    docker run --rm -i -t --name web_wp HUB-USER-NAME/jessie-wordpress

Podemos tambem executar iterativamente assim:

    docker run --rm -i -t --name web_wp \
           -p 8085:80 -p 2285:22            \
           -e ROOT_PASSWORD=xyz             \
           -v ./test/site:/var/www/html     \
           HUB-USER-NAME/jessie-wordpress start-all

Ou preferencialmente no modo Daemon assim:

    docker run -d --name web_wp         \
           -p 8085:80 -p 2285:22            \
           -e ROOT_PASSWORD=xyz             \
           -v ./test/site:/var/www/html     \
           HUB-USER-NAME/jessie-wordpress start-all

Observe o mapeamento da porta 80 do Apache dentro do contêiner 
para uso externo em 8085. O valor 8085 pode ser alterado a seu critério.
Você pode inclusive usar a porta 80 se tiver direitos para isso e se 
não estiver ocupada.

A porta 22 do SSH também foi mapeada e neste caso para 2285.

Também foi definido um diretório no host para ser montado 
em /var/www/html

Desta forma os Desenvolvedores poderão modificar os programas 
no computador Host usando as ferramentas visuais adequadas
(IDE, Browser, etc) pois as mudanças refletem imediatamente no 
Contêiner e são vistas pelo runtime do Apache e do PHP.

Verificando o Log

    docker logs web_wp

Para ver apenas a password do usuário root que foi definida para 
uso via SSH use o comando abaixo:

    docker logs web_wp 2> /dev/null | grep  "senha de root"

Podemos então abrir uma sessão SSH com o contêiner. No caso de 
usar o Docker num Host com **MAC OSX** podemos fazer:

    ssh -p 2285 root@$(docker-ip)

docker-ip é uma função criado no `.bash_profile` por conveniência. 
Veja o fonte abaixo:

    docker-ip() {
      boot2docker ip 2> /dev/null
    }

Para abrir uma sessão SSH com o contêiner quando
usar o Docker num Host **Linux**, Ubuntu por exemplo, 
podemos fazer:

    ssh -p 2285 root@localhost

Para testar a conexão com o Banco de Dados podemos usar:

    docker exec web_wp php /var/www/html/testecli.php

Após executar o sistema por um tempo, podemos parar o contêiner 
novamente para manutenção

    docker stop web_wp

e depois iniciá-lo novamente e observar o log

    docker start web_wp && sleep 10 && docker logs web_wp

Observe que **o LOG é acumulativo** e que agora não é executado o 
processo de Inicialização do Database, criação de usuários no MySQL, 
criação do nosso database, ajustes do PHP.INI, do HTTPD.CONF, etc. 

Você poderá ver o conteúdo do diretório /tmp executando o comando abaixo:

    docker exec web_wp ls -lat /tmp

Se você estiver usando o **MAC OSX** com Boot2Docker 
poderá executar o comando abaixo para abrir uma sessão como 
root no MySQL:

    open http://$(docker-ip):8085 

No Linux (Ubuntu por exemplo) use assim:

    open http://localhost:8085

A senha do MySQL para ser usada no programa PHP 
está Hard-coded no arquivo run.sh, mas apenas 
por motivos didáticos. 

Veja a variável `MYSQL_ROOT_PASSWORD` na shell run.sh

## Diretórios importantes:
    Configuração do Wordpress - /var/www/config
    Documentos do site - /var/www/html/wp-content
    PHP.INI            - /usr/local/etc/php e /usr/local/etc/php/conf.d
    Extensões PHP      - /usr/src/php/ext
    Logs do Apache     - /var/log/apache2
    Logs do MySQL      - /var/log/mysql
    Logs do PHP        - /var/log  (configurado em config/php.ini)

Exemplo de uso do comando `docker exec` para ver o Log do MySQL

    docker exec web_wp cat /var/log/mysql/error.log

Da mesma forma, para verificar a configuração do PHP use:

    docker exec web_wp cat /usr/local/etc/php/php.ini

#### Mais detalhes sobre Docker no meu Blog: [http://joao-parana.com.br/blog/](http://joao-parana.com.br/blog/)

