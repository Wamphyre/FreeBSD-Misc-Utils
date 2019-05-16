#!/bin/bash

clear

echo "Que combinacion de entrada/salida quieres usar?"

echo ""

echo "OPCIONES: "

echo ""

echo "1 - Entrada USB + Auriculares USB"
echo "2 - Entrada USB + Altavoces"

echo ; read -p "Dime opcion (elige 1 o 2): " OPCION;

if [ "$OPCION" = "1" ]; then

echo "Lanzando JACK server..."

echo ""

jackd -r -m -d oss -r 48200 -p2048 -C /dev/dsp6 -P /dev/dsp6 &

sleep 3

echo ""

echo "Lanzando JACK UMIDI Server..."

echo ""

jack_umidi -d /dev/umidi1.0 -B &

sleep 3

elif [ "$OPCION" = "2" ]; then

echo "Lanzando JACK server..."

echo ""

jackd -r -m -d oss -r 48200 -p2048 -C /dev/dsp6 -P /dev/dsp &

sleep 3

echo ""

echo "Lanzando JACK UMIDI Server..."

echo ""

jack_umidi -d /dev/umidi1.0 -B &

sleep 3

fi
