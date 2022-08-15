#!/bin/bash

# XFCE installer for FreeBSD

# Change /etc/pkg/FreeBSD.conf quarterly repo to use the latest repo
sed -i '' 's/quarterly/latest/g' /etc/pkg/FreeBSD.conf

# Update repositories and upgrade packages
pkg update && pkg upgrade -y

# Install XFCE and dependencies
pkg install -y xfce xfce4-goodies slim 

# Configure .xinitrc for root  
echo "exec startxfce4" > /root/.xinitrc

# Configure .xinitrc for user
echo ; read -p "For which user do you want to configure .xinitrc? " user
echo "exec startxfce4" > /home/$user/.xinitrc

# Get FreeBSD ports
portsnap fetch auto

# Compile nvidia-drivers from ports
cd /usr/ports/x11/nvidia-drivers && make install clean BATCH=yes

# Compile nvidia-settings from ports
cd /usr/ports/x11/nvidia-settings && make install clean BATCH=yes

# Compile nvidia-xconfig from ports
cd /usr/ports/x11/nvidia-xconfig && make install clean BATCH=yes

# Load linux compatibility layer
kldload linux.ko

# Add it to sysrc
sysrc nvidia_enable=YES
sysrc linux_enable=YES

# Load nvidia driver to next boot and create xconfig
echo 'nvidia-modeset_load="YES"' >> /boot/loader.conf
nvidia-xconfig

# Configure PF firewall
sysrc pf_enable=YES
sysrc pf_rules="/etc/pf.conf"

# Add default rules to pf.conf
echo 'block in all' >> /etc/pf.conf
echo 'pass out all keep state' >> /etc/pf.conf

# Other stuff
sysrc moused_enable="YES"
sysrc dbus_enable="YES"
sysrc hald_enable="YES"
sysrc slim_enable="YES"
sysrc ntpd_enable="YES"
sysrc ntpdate_enable="YES"
sysrc powerd_enable="YES"
sysrc powerd_flags="-a hiadaptive"
sysrc clear_tmp_enable="YES"
sysrc syslogd_flags="-ss"
sysrc sendmail_enable="NONE"
sysrc dumpdev="NO"
