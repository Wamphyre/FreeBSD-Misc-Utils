#!/bin/bash

#xfce_desktop by Wamphyre
#Version 1.0

test $? -eq 0 || exit 1 "Necesitas ser root para ejecutar este script"

echo "Bienvenido al Script Selector"

echo ""; sleep 3

echo "Este script instala un entorno de escritorio XFCE completo, optimizado y seguro"

echo ""; sleep 3

echo "AVISO¡¡ EJECUTA SOLO ESTE SCRIPT EN UN SISTEMA LIMPIO"

echo ""

sleep 5

sed -i '' 's/quarterly/latest/g' /etc/pkg/FreeBSD.conf

echo "Primero, actualicemos el gestor de paquetes y todos los paquetes del sistema"

echo ""; sleep 3

pkg update && pkg upgrade -y

echo ""

echo "Gestor de paquetes y paquetes instalados actualizados"

echo ""; sleep 3

echo "Obteniendo arbol de Ports";

echo ""

sleep 3

portsnap fetch auto

echo ""

sleep 3

echo "Arbol de ports extraido"

echo ""

sleep 3

echo "Instalando XFCE..."

echo ""

sleep 1

pkg install -y xorg slim xfce xfce4-goodies xfce4-pulseaudio-plugin thunar-archive-plugin xarchiver unzip sudo bash wget htop gnome-keyring gnome-screenshot gnome-font-viewer vlc audacious audacious-plugins firefox chromium

sysrc moused_enable="YES"
sysrc dbus_enable="YES"
sysrc hald_enable="YES"
sysrc slim_enable="YES"

echo ""

cd

touch .xinitrc

echo 'exec xfce4-session' >> .xinitrc

echo ""

echo ; read -p "¿Quieres habilitar XFCE para otro usuario?: " X;

echo ""

if [ "$X" = "si" ]

then

echo ; read -p "Dime usuario: " user;

touch /usr/home/$user/.xinitrc

echo 'exec xfce4-session' >> /usr/home/$user/.xinitrc

echo ""

echo "$user habilitado"

else fi

echo ""

kldload linux.ko

sysrc linux_enable="YES"

cd /usr/ports/x11/nvidia-driver
make install clean BATCH=yes
cd /usr/ports/x11/nvidia-settings
make install clean BATCH=yes
cd /usr/ports/x11/nvidia-xconfig
make install clean BATCH=yes

echo 'nvidia-modeset_load="YES"' >> /boot/loader.conf

nvidia-xconfig

echo ""

echo "Driver instalado"

echo ""

echo "Optimizando Sistema"

echo ""

sleep 2

mv /etc/sysctl.conf /etc/sysctl.conf.bk
touch /etc/sysctl.conf
echo 'hw.snd.default_unit=6' >> /etc/sysctl.conf
echo 'kern.timecounter.alloweddeviation=0' >> /etc/sysctl.conf
echo 'hw.usb.uaudio.buffer_ms=2' >> /etc/sysctl.conf
echo 'dev.pcm.6.bitperfect=1' >> /etc/sysctl.conf
echo 'hw.snd.latency=2' >> /etc/sysctl.conf
echo 'kern.coredump=0' >> /etc/sysctl.conf
echo 'kern.sched.preempt_thresh=224' >> /etc/sysctl.conf
echo 'kern.sched.slice=3' >> /etc/sysctl.conf
echo 'hw.snd.feeder_rate_quality=3' >> /etc/sysctl.conf
echo 'hw.snd.maxautovchans=32' >> /etc/sysctl.conf
echo 'kern.ipc.shm_allow_removed=1' >> /etc/sysctl.conf
echo 'snd_hda="YES"' >> /boot/loader.conf
echo 'mixer_enable="YES"' >> /boot/loader.conf
echo 'hw.usb.no_pf=1' >> /boot/loader.conf
echo 'hw.usb.no_boot_wait=0' >> /boot/loader.conf
echo 'hw.usb.no_shutdown_wait=1' >> /boot/loader.conf
echo 'hw.psm.synaptics_support=1' >> /boot/loader.conf
echo 'kern.cam.scsi_delay=10000' >> /boot/loader.conf
echo 'cuse_load="YES"' >> /boot/loader.conf

touch /etc/pf.conf
echo 'block in all' >> /etc/pf.conf
echo 'pass out all keep state' >> /etc/pf.conf
sysrc pf_enable="YES"
sysrc pf_rules="/etc/pf.conf" 
sysrc pf_flags=""
sysrc pflog_enable="YES"
sysrc pflog_logfile="/var/log/pflog"
sysrc pflog_flags=""
sysrc ntpd_enable="YES"
sysrc ntpdate_enable="YES"
sysrc powerd_enable="YES"
sysrc powerd_flags="-a hiadaptive"
sysrc clear_tmp_enable="YES"
sysrc syslogd_flags="-ss"
sysrc sendmail_enable="NONE"
sysrc dumpdev="NO"
webcamd_enable="YES"

echo "Sistema optimizado"

sleep 2

echo ""

echo "Actualizando microcódigo de la CPU..."

echo ""

sleep 2

pkg install -y devcpu-data

sysrc microcode_update_enable="YES"

service microcode_update start

echo ""

echo "Microcódigo actualizado"

echo ""

echo "Limpiando Sistema"

echo ""

sleep 1

pkg clean -y

echo ""

echo "Sistema limpio"

echo ""

echo "Por favor, reinicia ahora tu sistema"

echo ""

echo "xfce_desktop by Wamphyre :)"

echo ""
