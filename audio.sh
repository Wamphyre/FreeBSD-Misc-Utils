#!/bin/bash

echo ; read -p "¿Quieres usar los auriculares?: " respuesta;

if [ "$respuesta" = "si" ] ;

then sysctl hw.snd.default_unit=1

echo "";

echo "Auriculares activos";

else sysctl hw.snd.default_unit=0;

echo "";

echo "Usando altavoces";

fi
