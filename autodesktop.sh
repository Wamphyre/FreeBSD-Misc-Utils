#!/bin/bash
echo AutoDesktop by Wamphyre
echo Version 1.0

test $? -eq 0 || exit 1 "Necesitas ser root para ejecutar este script"

cd

echo Bienvenido al script de instalación AutoDesktop
sleep 1

echo ¡¡ADVERTENCIA¡¡ Este Script debe ejecutarse en un sistema FreeBSD recien instalado y limpio.
echo Instalaremos un entorno de escritorio XFCE completo y funcional con los ultimos drivers NVIDIA.
sleep 1

echo ¡¡ADVERTENCIA¡¡ Este Script solo es compatible con GPUs NVIDIA
echo Tienes 10 segundos para comenzar el proceso o cancelarlo pulsando ctrl+c
sleep 10

echo Vamos a actualizar los repositorios de FreeBSD...
sleep 1

echo Iniciando actualizacion...
pkg update && pkg upgrade -y

echo Repositorios y paquetes actualizados.
sleep 1

echo Comenzando actualización del sistema base...
freebsd-update fetch && freebsd-update install

echo Sistema Operativo actualizado
sleep 2

echo Actualizando y extrayendo el arbol de ports...
sleep 2

portsnap fetch auto

echo Arbol de ports actualizado.
sleep 1

echo Comenzando instalacion de Stack AutoDesktop...Ten paciencia.
sleep 3

pkg install -y nano xorg slim xfce curl wget htop
sleep 3
pkg install xarchiver-0.5.4.7 zip rar xfce4-volumed-pulse-0.2.2 xfce4-goodies-4.12_1 thunar-archive-plugin numix-theme-2.6.7 mate-icon-theme-faenza-1.18.1 slim-themes-1.0.1_1 iridium-browser-58.0_12 deadbeef filezilla bluefish gimp claws-mail-3.16.0 openshot frei0r-plugins audacity jamin transmission-2.92  
echo Comenzando configuracion post-instalacion...
sleep 3

sysrc slim_enable="YES"
sysrc moused_enable="YES"
sysrc dbus_enable="YES"
sysrc hald_enable="YES"
sysrc linux_enable="YES"
sysrc ntpd_enable="YES"
sysrc ntpdate_enable="YES"
sysrc powerd_enable="YES"
sysrc powerd_flags="-a hiadaptive"
kldload linux.ko

touch .xinitrc
echo 'exec xfce4-session' >> .xinitrc

echo Compilando e instalando los ultimos drivers NVIDIA disponibles...
sleep 3

cd /usr/ports/x11/nvidia-driver
make install clean BATCH=yes
cd /usr/ports/x11/nvidia-settings
make install clean BATCH=yes
cd /usr/ports/x11/nvidia-xconfig
make install clean BATCH=yes
echo 'nvidia-modeset_load="YES"' >> /boot/loader.conf
nvidia-xconfig

echo Instalacion driver NVIDIA finalizada
sleep 2

echo Aplicando parámetros de Hardening Paranóico...
sleep 3

pkg audit -F

sysrc pf_enable="YES"
sysrc pflog_enable="YES"
sysrc clear_tmp_enable="YES"
sysrc syslogd_flags="-ss"
sysrc sendmail_enable="NONE"
sysrc dumpdev="NO"

echo 'kern.elf64.nxstack=1' >> /etc/sysctl.conf
echo 'sysctl security.bsd.map_at_zero=0' >> /etc/sysctl.conf
echo 'security.bsd.see_other_uids=0' >> /etc/sysctl.conf
echo 'security.bsd.see_other_gids=0' >> /etc/sysctl.conf
echo 'security.bsd.unprivileged_read_msgbuf=0' >> /etc/sysctl.conf
echo 'security.bsd.unprivileged_proc_debug=0' >> /etc/sysctl.conf
echo 'kern.randompid=1000' >> /etc/sysctl.conf
echo 'security.bsd.stack_guard_page=1' >> /etc/sysctl.conf
echo 'net.inet.udp.blackhole=1' >> /etc/sysctl.conf
echo 'net.inet.tcp.blackhole=2' >> /etc/sysctl.conf
echo 'kern.ipc.shm_allow_removed=1' >> /etc/sysctl.conf

echo Hardening Paranóico completado.
sleep 3

echo Limpiando y revisando el sistema...
sleep 4

pkg update && pkg upgrade -y
pkg clean -y

echo ¡Instalación finalizada¡
echo Tu entorno de escritorio XFCE4 para FreeBSD con drivers NVIDIA Latest ya está instalado, configurado y securizado.
sleep 2

echo ¡¡¡¡NOTAS IMPORTANTES¡¡¡¡
echo No elimines el fichero .xinitrc, no arrancara el gestor de escritorio
echo Puedes instalar ahora cualquier programa usando los comandos "pkg search" para buscar un paquete, "pkg install" para instalar ese paquete y "pkg remove" para eliminarlo
echo Igualmente puedes compilar e instalar desde codigo fuente en /usr/ports, localizando el paquete que deseas y escribiendo "make install clean"
echo Si tienes dudas, consulta el handbook en la web de FreeBSD
sleep 2

echo Reinicia tu sistema para disfrutar de tu nuevo entorno de escritorio.

exit
