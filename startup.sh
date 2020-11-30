# -----
# Experimental script used to create the mysqlnd_azure binary during Web App startup.
# -----

if [ -f "/home/site/wwwroot/bin/mysqlnd_azure.so" ]; then
    echo "mysqlnd_azure present, no need to install."
else
    # If not, build and store to /bin
    apt install git -y
    git clone https://github.com/microsoft/mysqlnd_azure --depth 1
    cd mysqlnd_azure
    phpize
    ./configure
    make

    cp ./modules/mysqlnd_azure.so /home/site/wwwroot/bin/mysqlnd_azure.so
fi

# Continue as normal / indicate error and restart.
