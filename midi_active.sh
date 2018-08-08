#!/bin/bash

echo "Arrancando JACK server"

echo ""

jackd -r -m -d oss -r 48200 -p2048 -C /dev/dsp6 -P /dev/dsp3 &

echo ""

echo "Arrancando JACK MIDI"

echo ""

jack_umidi -d /dev/umidi1.0 -B

echo ""

echo "Mostrando salida de dispositivos de audio"

echo ""

jack_lsp
