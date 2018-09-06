#!/bin/bash

clear

echo "======== Welcome to Ajenti CP Installer ========"

echo "                                     by Wamphyre"

echo ""

echo "________________________________________________"

echo ""

sleep 2

echo "Updating PKG repository"

sleep 2

echo ""

pkg update && pkg upgrade -y 

echo ""

echo "Installing Python prerequisites"

sleep 2

echo ""

pkg install -y py27-pip py27-ldap py27-lxml py27-gevent libffi wget

pip install --upgrade pip

echo ""

echo "Python requisites installed"

sleep 2

echo ""

echo "Installing Ajenti Control Panel"

echo ""

sleep 2

pip install ajenti

echo ""

echo "Ajenti Control Panel Installed"

echo ""

sleep 2

echo "Installing Ajenti RC conf"

echo ""

sleep 2

wget https://raw.githubusercontent.com/ajenti/ajenti/1.x/packaging/files/ajenti-bsd -O /etc/rc.d/ajenti

chmod a+x /etc/rc.d/ajenti

mkdir /usr/local/etc/ajenti

wget https://raw.githubusercontent.com/ajenti/ajenti/1.x/packaging/files/config.json -O /usr/local/etc/ajenti/config.json

service ajenti start

echo ""

echo "Installation Finished"

echo ""

AJENTI=$( curl -s ifconfig.me );echo "Ajenti Control Panel listening on "$AJENTI":8000"
