#!/bin/bash

echo ; read -p "Dime usuario a realizar backup: " USER;

echo ; read -p "Dime web a crear copia: " WEB;

FECHA=$(date -I)

mkdir /usr/local/www/backup/$USER

mkdir /usr/local/www/backup/$USER/$FECHA

tar -czvf $WEB-$FECHA.tar.gz /usr/home/$USER/public_html/$WEB

DATABASE=$(cat /usr/home/$USER/public_html/$WEB/wp-config.php | grep -i "DB_NAME" | cut -d "'" -f4)

mysqldump -p $DATABASE > $DATABASE.sql

mv $WEB-$FECHA.tar.gz /usr/local/www/backup/$USER/$FECHA

mv $DATABASE.sql /usr/local/www/backup/$USER/$FECHA

echo "Copia web y base de datos completada"
