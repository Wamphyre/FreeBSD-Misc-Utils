#!/bin/sh
echo "Autowordpress by Wamphyre"
echo "Version 1.0"

test $? -eq 0 || exit 1 "Necesitas ser root para ejecutar este script"

echo "Descargando Wordpress...";
fetch http://wordpress.org/latest.zip;
unzip -q latest.zip;

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
chown -R www:www /usr/local/www/public_html/
chown -R www:www /usr/local/www/public_html/*
find . -type f -exec chmod 664 {} +
find . -type d -exec chmod 775 {} +

echo "Finalizado!";
