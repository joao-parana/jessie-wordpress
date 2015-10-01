# jessie-lamp

> Imagem Docker para **Stack LAMP** usando Debian Jessie (version 8),
> Apache WebServer, o MySQL 5.6.26 e o PHP versão 5.6 (A versão 7 ainda 
> não foi liberada)

Este projeto foi testado com a **versão 1.8.2** do Docker

Usado no curso [http://joao-parana.com.br/blog/curso-docker/](http://joao-parana.com.br/blog/curso-docker/) criado para a Escola Linux.

Neste repositório temos dois Releases deste projeto.

1. A versão 1.0.* está apenas com o LAMP (sem o SSH Server)
2. A versão 2.0.* está com LAMP e SSH Server como mostrado na imagem abaixo.

Veja no Diagrama abaixo o contêiner, o Volume, e as portas do Apache e do SSH

![https://raw.githubusercontent.com/joao-parana/jessie-lamp/master/docs/img/jessie-lamp.png](https://raw.githubusercontent.com/joao-parana/jessie-lamp/master/docs/img/jessie-lamp.png)

Criando a imagem

    docker build -t HUB-USER-NAME/jessie-lamp  .

Substitua o token `HUB-USER-NAME` pelo seu login em [http://hub.docker.com](http://hub.docker.com)


Usaremos aqui o nome `web_jessie` para o Contêiner.
Caso exista algum conteiner com o mesmo nome rodando, 
podemos pará-lo assim:

    docker stop web_jessie

> Pode demorar alguns segundos para parar e isto é normal.

Em seguida podemos removê-lo

    docker rm web_jessie

Podemos executar o Contêiner iterativamente para obter um help assim:

    docker run --rm -i -t --name web_jessie HUB-USER-NAME/jessie-lamp

Podemos tambem executar iterativamente assim:

    docker run --rm -i -t --name web_jessie \
           -p 8085:80 -p 2285:22            \
           -e ROOT_PASSWORD=xyz             \
           -v ./test/site:/var/www/html     \
           HUB-USER-NAME/jessie-lamp start-all

Ou preferencialmente no modo Daemon assim:

    docker run -d --name web_jessie         \
           -p 8085:80 -p 2285:22            \
           -e ROOT_PASSWORD=xyz             \
           -v ./test/site:/var/www/html     \
           HUB-USER-NAME/jessie-lamp start-all

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

    docker logs web_jessie

Para ver apenas a password do usuário root que foi definida para 
uso via SSH use o comando abaixo:

    docker logs web_jessie 2> /dev/null | grep  "senha de root"

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

    docker exec web_jessie php /var/www/html/testecli.php

Após executar o sistema por um tempo, podemos parar o contêiner 
novamente para manutenção

    docker stop web_jessie

e depois iniciá-lo novamente e observar o log

    docker start web_jessie && sleep 10 && docker logs web_jessie

Observe que **o LOG é acumulativo** e que agora não é executado o 
processo de Inicialização do Database, criação de usuários no MySQL, 
criação do nosso database, ajustes do PHP.INI, do HTTPD.CONF, etc. 

Você poderá ver o conteúdo do diretório /tmp executando o comando abaixo:

    docker exec web_jessie ls -lat /tmp

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

    Documentos do site - /var/www/html
    PHP.INI            - /usr/local/etc/php e /usr/local/etc/php/conf.d
    Extensões PHP      - /usr/src/php/ext
    Logs do Apache     - /var/log/apache2
    Logs do MySQL      - /var/log/mysql
    Logs do PHP        - /var/log  (configurado em config/php.ini)

Exemplo de uso do comando `docker exec` para ver o Log do MySQL

    docker exec web_jessie cat /var/log/mysql/error.log

Da mesma forma, para verificar a configuração do PHP use:

    docker exec web_jessie cat /usr/local/etc/php/php.ini


## Testando o ambiente

Pagina WEB de teste:

    <?php ?>
    <!DOCTYPE html>
    <!--[if lt IE 7]>      <html class="no-js lt-ie9 lt-ie8 lt-ie7"> <![endif]-->
    <!--[if IE 7]>         <html class="no-js lt-ie9 lt-ie8"> <![endif]-->
    <!--[if IE 8]>         <html class="no-js lt-ie9"> <![endif]-->
    <!--[if gt IE 8]><!--> <html class="no-js"> <!--<![endif]-->
      <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        <title></title>
        <meta name="description" content="">
        <meta name="viewport" content="width=device-width">
        <script src="//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
      </head>
      <body>
        <!--[if lt IE 7]>
          <p class="chromeframe">You are using an <strong>outdated</strong> browser.
          Please <a href="http://browsehappy.com/">upgrade your browser</a> or
          <a href="http://www.google.com/chromeframe/?redirect=true">
            activate Google Chrome Frame
          </a> to improve your experience.</p>
        <![endif]-->

        <div>Servidor : <span id="server_name">
          <?php echo $_SERVER['SERVER_NAME']; ?></span><br><br>
          Browser: <?php echo $_SERVER["HTTP_USER_AGENT"]; ?><br><br>
          Versão do PHP: <?php echo $_ENV["PHP_VERSION"] ?><br><br>
        </div>
        <br><br>
        Você está vendo o nome do servidor ou endereço IP ?
        Isto indica que  o PHP está OK.
        <br><br>
        <div>
          ATENÇÃO: Verifique abaixo se o valor de memory_limit é o mesmo
          definido no Dockerfile via comando ENV.
          Isto significa que a configuração flexivel do PHP também está OK.
        </div>
        <script>
          console.log('<?php echo 'Servidor: ' .
                      $_SERVER['SERVER_NAME']; ?>');

          if ($('#server_name').text()) {
            alert('Veio Server Name =' + $('#server_name').text());
          }
        </script>
        <?php phpinfo(); ?>
      </body>
    </html>

## Diferenças entre a versão 1 e a versão 2

Foram adicionados os arquivos:

Arquivo: [set_root_pw.sh](https://github.com/joao-parana/jessie-lamp/blob/master/set_root_pw.sh)

Arquivo: [start-all](https://github.com/joao-parana/jessie-lamp/blob/master/start-all)

Foram alterados os arquivos:

    Dockerfile
    README.md
    docker-entrypoint.sh
    run-container

Veja abaixo as modificações no Dockerfile para suportar o SSH

![https://raw.githubusercontent.com/joao-parana/jessie-lamp/master/docs/img/diff-dockerfile.png](https://raw.githubusercontent.com/joao-parana/jessie-lamp/master/docs/img/diff-dockerfile.png)

Veja abaixo as modificações no docker-entrepoint.sh para suportar o SSH

![https://raw.githubusercontent.com/joao-parana/jessie-lamp/master/docs/img/diff-entrypoint.png](https://raw.githubusercontent.com/joao-parana/jessie-lamp/master/docs/img/diff-entrypoint.png)

As alaterações ao final são apenas melhoria no Help.


#### Mais detalhes sobre Docker no meu Blog: [http://joao-parana.com.br/blog/](http://joao-parana.com.br/blog/)

