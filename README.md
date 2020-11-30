# Azure Redirect for Azure MySQL/MariaDB on Linux Azure Web Apps PHP 7.4 without Docker

This approach is using the mysqlnd_azure.so extension to enable the [redirection functionality](https://docs.microsoft.com/azure/mariadb/howto-redirection) on Azure MySQL/MariaDB instance.

1. Build the *mysqlnd_azure.so* binary with `make` (using Docker container or locally). You can follow [these steps](https://github.com/microsoft/mysqlnd_azure#step-to-build-on-linux).

    ```bash
    # Using the appsvc/php:7.4-apache_20200522.6 Docker image.
    apt install git -y
    git clone https://github.com/microsoft/mysqlnd_azure --depth 1
    cd mysqlnd_azure
    phpize
    ./configure
    make
    # If successful, the binary will be in ./modules/mysqlnd_azure.so.
    ```

    1. Extract the binary from the container (if using Docker): `docker cp <container_id>:/home/mysqlnd_azure/modules/mysqlnd_azure.so <dest_path>`.

1. Add the newly created binary to your project (for instance to a `./bin` folder).
1. Create a configuration INI file (for instance in an `./ini` folder).
1. Add the following to the file:

    ```ini
    extension=/home/site/wwwroot/bin/mysqlnd_azure.so
    mysqlnd_azure.enableRedirect = on
    ```

1. [Change the INI scan directory](https://docs.microsoft.com/azure/app-service/configure-language-php?pivots=platform-linux#customize-php_ini_system-directives) for your Web App.

    ```bash
    az webapp config appsettings set --name <app-name> --resource-group <resource-group-name> --settings PHP_INI_SCAN_DIR="/usr/local/etc/php/conf.d:/home/site/wwwroot/ini"
    ```

    > Note: This is a simplistic approach. Microsoft documentation recommends creating the `ini` folder outside of `wwwroot` using SSH.

1. Push to the repo and deploy the app.
1. Don't fogert to change the `redirect_enabled` setting to *ON* on you Azure MySQL/MariaDB instance.

The directory structure then can look like this:

```
|- bin
  |-mysqlnd_azure.so
|- ini
  |-mysqlnd_setting.ini
|- index.php
```

Finally, test the connection via PHP:

```php
<?php
// Based on: https://docs.microsoft.com/azure/mariadb/howto-redirection

$host = getenv("DB_HOST");
$username = getenv("DB_USERNAME");
$password = getenv("DB_PASSWORD");
$db_name = getenv("DB_NAME");

echo "mysqlnd_azure.enableRedirect: ", ini_get("mysqlnd_azure.enableRedirect"), "\n";
$db = mysqli_init();

//The connection must be configured with SSL for redirection test
$link = mysqli_real_connect ($db, $host, $username, $password, $db_name, 3306, NULL, MYSQLI_CLIENT_SSL);

if (!$link) {
    die ('Connect error (' . mysqli_connect_errno() . '): ' . mysqli_connect_error() . "\n");
}
else {
    echo $db->host_info, "\n"; //if redirection succeeds, the host_info will differ from the hostname you used used to connect
    $res = $db->query('SHOW TABLES;'); //test query with the connection
    print_r ($res);
    $db->close();
}
?>
```
