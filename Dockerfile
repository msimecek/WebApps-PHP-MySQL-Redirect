FROM appsvc/php:7.4-apache_20200522.6
ENV ACCEPT_EULA=Y
RUN apt update && apt upgrade -y
RUN pecl install mysqlnd_azure