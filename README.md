# jessie-wordpress

> Imagem Docker para **Stack LAMP** com **Wordpress** usando Debian Jessie (version 8),
> Apache WebServer, o MySQL 5.6, o PHP versão 5.6 (A versão 7 ainda 
> não foi liberada)

Este projeto foi testado com a **versão 1.8.2** do Docker

Usado no curso [http://joao-parana.com.br/blog/curso-docker/](http://joao-parana.com.br/blog/curso-docker/) criado para a Escola Linux.

Veja no Diagrama abaixo o contêiner, o Volume, e as portas do Apache e do SSH

![https://raw.githubusercontent.com/joao-parana/jessie-lamp/master/docs/img/jessie-lamp.png](https://raw.githubusercontent.com/joao-parana/jessie-lamp/master/docs/img/jessie-lamp.png)

O Wordpress depende da Stack LAMP mas também possui uma estrutura que mistura 
configuração, código PHP do núcleo, traduções, temas e plugins. Isto dificulta
o uso de um Workflow para Desenvolvimento, Teste, Homologação e Produção.

A figura abaixo ilustra estas dependências

![dependencias wp](https://raw.githubusercontent.com/joao-parana/jessie-wordpress/master/docs/img/dependencias-wp.png)

A solução proposta aqui é usar volumes e links simbólicos para facilitar 
o trabalho. Obviamente poderiamos usar outra abordagem. Esta foi uma das 
escolhas possíveis.

Veja abaixo a proposta de estrutura de diretório para nosso projeto

![estrutura de diretorio](https://raw.githubusercontent.com/joao-parana/jessie-wordpress/master/docs/img/estrutura-de-diretorio.png)

## Instalação e Configuração

### WP-CLI

A CLI (Command Line Interface) wp permite realizar várias tarefas no Wordpress 
de forma programática.

Por exemplo, podemos fazer:

* o download do Wordpress (comando `core download`)
* a edição do wp-config.php (comando `core config`)
* a configuração inicial do Wordpress (comando `core install`) 

O comando `core download` não recebe nenhum parâmetro e baixa a ultima versão 
estável do Wordpress.

O comando `core config` recebe como parâmetros `dbname`, `dbuser`, `dbpass` e `dbhost`. 
O dbhost deve ser especificado como `127.0.0.1` em vez de `localhost` que é o padrão.

O comando `core install` recebe como parâmetros os dados do site: 
`url`, `title`, `admin_user`, `admin_password` e `admin_email`. 

Em certas circunstâncias necessitamos editar algum parâmetro no wp-config.php.

Neste caso podemos criar uma função na nossa shell com o seguinte código:

    set_config() {
      key="$1"
      value="$2"
      php_escaped_value="$(php -r 'var_export($argv[1]);' "$value")"
      sed_escaped_value="$(echo "$php_escaped_value" | sed 's/[\/&]/\\&/g')"
      sed -ri "s/((['\"])$key\2\s*,\s*)(['\"]).*\3/\1$sed_escaped_value/" wp-config.php
    }

Isto permite invocá-la, por exemplo, assim:

    set_config 'DB_HOST' "127.0.0.1"




### PHP

O arquivo `/usr/local/php/conf.d/uploads.ini` poderia ter um conteúdo 
como este abaixo para permitir uploads de arquivos de até 256 Megabytes.

    file_uploads = On
    memory_limit = 256M
    upload_max_filesize = 256M
    post_max_size = 300M
    max_execution_time = 600

## Usando o Docker

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

**ATENÇÃO:** Lembre-se que ao remover um contêiner você destroi o seu estado
e isso inclui qualquer dado persistido em seu filesystem, então tome muito
cuidado ao fazer isso. 

Podemos executar o Contêiner iterativamente, forçando sua remoção ao sair. 
Isso pode ser feito para obter um help das opções:

    docker run --rm -i -t HUB-USER-NAME/jessie-wordpress

Quando não especificamos um nome para o contêiner o docker cria um nome arbitrário.

Podemos executar iterativamente, como mostrado abaixo, mantendo o contêiner 
nomeado `web_wp` com o Wordpress e o WP-CLI instalados e configurados. 

    docker run -i -t --name web_wp -p 80:80 -p 2285:22 parana/jessie-wordpress

Você poderá verificar que ele permanece na lista de contêineres no seu host.

    docker ps -a

Caso você **pare** (`docker stop web_wp`) o contêiner, também poderá 
iniciar novamente a qualquer momento usando o comando :

    docker start  web_wp

Podemos verificar o LOG assim: 

    docker logs  web_wp

Veremos as mensagens indicando que na primeira vez o WP_CLI é instalado 
e nas outras vezes apenas usado para ecoar as informações. 

A nível de Banco de Dados MySQL são feitas as seguintes configurações iniciais
no contêiner por padrão:

* Criação de usuário __root__ com senha randômica 
* Remoção do database __test__
* Criação de database __my-db__
* Criação de usuário __wp__ com senha __secret__
* Grant de privilégios ao usuário __wp__  no database  __my-db__
* Criação de tabela para _CRUDClass_ para teste de conexão ao database
* Inserção de registros 'João', 'Pedro' e 'Maria' para teste de SQL

## Executando o Wordpress

Este projeto cria um site usando BASE_URL `dockerhost.local`, 
título: `Título do SITE`, usuário: `admin`, senha: `minhasenha` e 
e-mail de admin informado pela variável de ambiente `WP_EMAIL_ADDR`

Assim, para facilitar os testes crie uma entrada no /etc/hosts do seu 
computador host para `dockerhost.local` apontando da seguinte forma:

* MAC OSX ou Windows : endereço obtido da execução de `boot2docker ip` 
* Linux : localhost

Podemos executar o conêiner iterativamente numa seção de teste passando um 
diretório como Volume com o comando abaixo:

    docker run --rm -i -t --name web_wp           \
           -p 80:80 -p 2285:22                    \
           -e ROOT_PASSWORD=xyz                   \
           -e WP_EMAIL_ADDR=joao.parana@gmail.com \
           -v ./test/site:/var/www/html           \
           HUB-USER-NAME/jessie-wordpress start-wordpress

A opção --rm remove o contêiner ao final de sua execução. Esta opção serve
durante o processo de desenvolvimento do contêiner pelo mantenedor.
Ela também serve para execução de testes unitários num workflow de 
integração contínua, por exemplo.

A variável de ambiente WP_EMAIL_ADDR precisa ser informada apenas na 
primeira vez quando será feita a configuração do site Wordpress.

Preferencialmente devemos executar no modo Daemon assim:

    docker run -d --name web_wp             \
           -p 80:80 -p 2285:22              \
           -e ROOT_PASSWORD=xyz             \
           -v ./test/site:/var/www/html     \
           HUB-USER-NAME/jessie-wordpress start-wordpress

Observe o mapeamento da porta 80 do Apache dentro do contêiner 
para uso externo em 80. Antes verifique se a porta 80 já está ocupada 
no seu computador host, pois isso causaria erro de rede.

A porta 22 do SSH foi mapeada para 2285.

Também foi definido um diretório no host para ser montado 
em /var/www/html

Desta forma os Desenvolvedores poderão modificar os programas 
no computador Host usando as ferramentas visuais adequadas
(IDE, Browser, etc) pois as mudanças refletem imediatamente no 
Contêiner e são vistas pelo runtime do Apache e do PHP.

## Verificando o Log

    docker logs web_wp

Para ver apenas a password do usuário root que foi definida para 
uso via SSH use o comando abaixo:

    docker logs web_wp 2> /dev/null | grep  "senha de root"

## Usando o SSH 

Podemos então abrir uma sessão SSH com o contêiner. No caso de 
usar o Docker num Host com **MAC OSX** podemos fazer:

    ssh -p 2285 root@$(docker-ip)

`docker-ip` é uma função criada no `.bash_profile` por conveniência. 
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

    open http://$(docker-ip):80 

No Linux (Ubuntu por exemplo) use assim:

    open http://localhost:80

A senha do MySQL para ser usada no programa PHP 
está Hard-coded no arquivo run.sh, mas apenas 
por motivos didáticos. 

Veja a variável `MYSQL_ROOT_PASSWORD` na shell run.sh

## Opções quando executar o Contêiner

As opções de parâmetro para o ENTRYPOINT são:
    --help            # opção padrão, quando não informada
    /bin/bash         # para investigação e fazer debug do contêiner
    start-wordpress   # workflow normal de desenvolvimento

## Diretórios importantes:
    Conteúdo Wordpress - /var/www/html/wp-content
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

## Resolução de Problemas

### Migrando o Site

Uma descrição completa de como funciona o processo de migração de site 
no Wordpress pode ser encontrada neste link: 
[Changing the site URL](https://codex.wordpress.org/Changing_The_Site_URL) 

Se você tiver problema para acessar este link veja o PDF gerado e disponível 
[aqui no meu github](https://github.com/joao-parana/jessie-wordpress/blob/master/docs/ChangingTheSiteURL.pdf)

#### Alterando WP_HOME e WP_SITEURL no arquivo wp-config.php

Podemos resumir assim:

Quando você encontra um problema durante a migração de um site de um 
endereço URL para outro, você pode usar uma sessão SSH e editar o `wp-config.php` 
adicionando/alterando as linhas abaixo:

    define('WP_HOME','http://yourdomainname.com.br');
    define('WP_SITEURL','http://yourdomainname.com.br');

#### Alterando RELOCATE no arquivo wp-config.php

Outra alternativa é alterar o valor de `RELOCATE` para `true` no `wp-config.php`

    define('RELOCATE', true);

e em seguida usar a URL: `http://yourdomainname.com.br/wp-login.php` para 
entrar no Site como Admin. Em seguida navegue para Settings > General e 
verifique as URLs para a HOME e para SITEURL. Salve as configurações 
e mude novamente o valor de RELOCATE no arquivo `wp-config.php`, mas 
agora para false.

    define('RELOCATE', false);

Observação: Quando o flag RELOCATE fica com true, o Site URL será atualizado
automaticamente pelo caminho que estivermos usando para acessar a tela de login.
Isto deixa a a seção de administração rodando na nova URL, permitindo
que façamos as alterações necessárias que devem ser salvas para o site voltar 
a funcionar plenamente.

#### Usando WP_CLI

Mais uma alternativa, agora usando WP_CLI

Como o nosso site de desenvolvimento está em `dockerhost.local` devemos fazer o seguinte:

    wp search-replace 'dockerhost.local' 'yourdomainname.com.br' --skip-columns=guid

Se desejarmos apenas mudar o valor de `option` podemos fazer o seguinte:

    wp option update home 'http://yourdomainname.com.br'
    wp option update siteurl 'http://yourdomainname.com.br'

ou, se desejar usar HTTPS: 

    wp option update home 'https://yourdomainname.com.br'
    wp option update siteurl 'https://yourdomainname.com.br'

