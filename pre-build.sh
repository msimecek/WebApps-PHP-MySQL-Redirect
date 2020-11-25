# Check if mysqlnd_azure.so present in /bin
if [ -f "/home/site/wwwroot/bin/mysqlnd_azure.so" ]; then
    echo "mysqlnd_azure present, no need to install."
else
    # If not, build and store to /bin
    apt install git
    git clone https://github.com/microsoft/mysqlnd_azure --depth 1
    cd mysqlnd_azure
    phpize
    ./configure
    make

    cp ./modules/mysqlnd_azure.so /home/site/wwwroot/bin/mysqlnd_azure.so
fi


