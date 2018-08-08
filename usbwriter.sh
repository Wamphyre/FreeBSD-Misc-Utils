#!/bin/bash

echo ""

echo -e "\e[93mBienvenido a Wamphyre USB Writer"

sleep 2;

echo ""

echo -e "\e[91mMostrando dispositivos de almacenamiento externo y sus particiones"

echo -e "\e[92m=================================================================="

echo ""

ls /dev/da*

echo ""

echo -e "\e[93m"; read -p "Que dispositivo quieres usar para grabar? (ejemplo /dev/da0): " DISPOSITIVO;

echo ""

echo -e "\e[93m"; read -p "Quieres formatear a CERO el dispositivo seleccionado?: " FORMATEO;

echo ""

if [ "$FORMATEO" = "si" ];

then echo -e "\e[91mEscribiendo ceros en todo el dispositivo..."; dd if=/dev/zero of=$DISPOSITIVO bs=2m count=1

echo ""

echo -e "\e[91mDispositivo limpio"

sleep 2;

else fi; 

echo -e "\e[93m"; read -p "En que directorio tienes la imagen que quieres grabar?: " RUTA;

echo ""

echo -e "\e[92m" ; ls $RUTA | egrep -e ".iso" -e ".img" -e ".usb" -e ".image"

echo ""

echo -e "\e[93m" ; read -p "Dime nombre completo de la imagen que vas a usar: " IMAGEN;

echo ""

echo -e "\e[93mSe va a grabar "$RUTA"/"$IMAGEN" en "$DISPOSITIVO" "

echo ""

echo -e "\e[91m"; read -p "ES CORRECTO?: " RESPUESTA

echo ""

if [ "$RESPUESTA" = "si" ] ;

then echo -e "\e[93mVa a comenzar la grabacion de $IMAGEN en $DISPOSITIVO, espera unos minutos y no cierres esta ventana";

echo ""

echo  -e "Grabando..." 

echo ""

dd if=$RUTA/$IMAGEN of=$DISPOSITIVO bs=1M conv=sync

echo ""

echo "Imagen grabada correctamente"

else echo "Saliendo..."; fi
