<?php

date_default_timezone_set('America/Sao_Paulo');

print_r('Testando via CLI do php. Usando o comando: ' . PHP_EOL .
        'docker exec web_jessie php /var/www/html/testecli.php');
print_r(PHP_EOL);

// http://zetcode.com/databases/mysqlphptutorial/ estruta OK mais obsoleto na API

$host = "127.0.0.1";
$user = "wp";
$pass = "secret";
$db = "my-db";
/*
  MYSQL_ROOT_PASSWORD=xpto
 */
$link = mysqli_connect($host, $user, $pass, $db);

if (!$link) {
    echo "Error: Unable to connect to MySQL." . PHP_EOL;
    echo "Debugging errno: " . mysqli_connect_errno() . PHP_EOL;
    echo "Debugging error: " . mysqli_connect_error() . PHP_EOL;
    exit;
}

echo "Success: A proper connection to MySQL was made! The my_db database is great." . PHP_EOL;
echo "Host information: " . mysqli_get_host_info($link) . PHP_EOL;

mysqli_close($link);

$r = mysqli_connect($host, $user, $pass, $db);

if (!$r) {
    echo "Could not connect to server\n";
    trigger_error(mysql_error(), E_USER_ERROR);
} else {
    echo "Connection established" . PHP_EOL;
}


$mysqli = new mysqli($host, $user, $pass, $db);

/*
 * This is the "official" OO way to do it,
 * BUT $connect_error was broken until PHP 5.2.9 and 5.3.0.
 */
if ($mysqli->connect_error) {
    die('Connect Error (' . $mysqli->connect_errno . ') '
            . $mysqli->connect_error);
}

/*
 * Use this instead of $connect_error if you need to ensure
 * compatibility with PHP versions prior to 5.2.9 and 5.3.0.
 */
if (mysqli_connect_error()) {
    die('Connect Error (' . mysqli_connect_errno() . ') '
            . mysqli_connect_error());
}

echo 'Success... ' . $mysqli->host_info . PHP_EOL;

$mysqli->close();

$mysqli = new mysqli($host, $user, $pass, $db);

// Oh no! A connect_errno exists so the connection attempt failed!
if ($mysqli->connect_errno) {
    // The connection failed. What do you want to do?
    // You could contact yourself (email?), log the error, show a nice page, etc.
    // You do not want to reveal sensitive information

    // Let's try this:
    echo "Sorry, this website is experiencing problems." . PHP_EOL;

    // Something you should not do on a public site, but this example will show you
    // anyways, is print out MySQL error related information -- you might log this
    echo "Error: Failed to make a MySQL connection, here is why: " . PHP_EOL;
    echo "Errno: " . $mysqli->connect_errno . PHP_EOL;
    echo "Error: " . $mysqli->connect_error . PHP_EOL;

    // You might want to show them something nice, but we will simply exit
    exit;
}

// Perform an SQL query
$sql = "select id, name, email from CRUDClass";
if (!$result = $mysqli->query($sql)) {
    echo "Sorry, the database is experiencing problems." . PHP_EOL;
    exit;
}

// Print our 5 random actors in a list, and link to each actor
echo "Inicio". PHP_EOL;
while ($linha = $result->fetch_assoc()) {
    echo $linha['id'] . ' ' . $linha['name'] . ' ' . $linha['email'] . PHP_EOL;
}
echo "Fim" . PHP_EOL;

// The script will automatically free the result and close the MySQL
// connection when it exits, but let's just do it anyways
$result->free();
$mysqli->close();
