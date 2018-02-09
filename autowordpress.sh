#!/bin/sh
echo "Autowordpress by Wamphyre"
echo "Version 1.0"

test $? -eq 0 || exit 1 "Necesitas ser root para ejecutar este script"

echo "Descargando Wordpress...";
wget http://wordpress.org/latest.zip;
unzip -q latest.zip;

echo "Descargando e instalando W3 Total Cache...";
wget http://downloads.wordpress.org/plugin/w3-total-cache.zip
unzip -q  w3-total-cache.zip;
mv w3-total-cache wordpress/wp-content/plugins/

echo "Limpiando directorio y archivos temporales...";
rm *.zip

mv wordpress/* .;
rm -rf wordpress;

echo "Creando htaccess..."
touch .htaccess
echo '<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>' >> .htaccess

echo "Reparando y estableciendo permisos..."
chown www:www .htaccess
chown -R www:www /usr/local/www/apache24/data/*
find . -type f -exec chmod 664 {} +
find . -type d -exec chmod 775 {} +

mv wp-config-sample.php wp-config.php

echo "Desactivando editor de archivos...";
echo "
/* Disable the file editor */
define(‘DISALLOW_FILE_EDIT’, true);" >> wp-config.php

echo "Desactivando uso de FTP para temas/plugins...";
echo "
/* Disable the FTP */
define(‘FS_METHOD’,’direct’);" >> wp-config.php

echo "Finalizado!";
