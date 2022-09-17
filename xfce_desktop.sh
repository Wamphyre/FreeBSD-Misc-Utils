#!/bin/bash

#xfce_desktop by Wamphyre
#Version 1.0

test $? -eq 0 || exit 1 "NEED TO BE ROOT TO RUN THIS"

echo "Welcome to BSD-XFCE base script"
echo "This will install a complete, secure and optimized XFCE desktop in your FreeBSD system"
echo "WARNING!! - Execute only in a fresh vanilla installation"

sleep 5

sed -i '' 's/quarterly/latest/g' /etc/pkg/FreeBSD.conf

echo "Upgrading packages..."

echo ""

pkg update && pkg upgrade -y

echo ""

echo "Downloading Ports tree...";

echo ""

portsnap fetch auto

echo ""

echo "Installing XFCE and basic utilities..."

echo ""

pkg install -y xorg slim xfce xfce4-pulseaudio-plugin thunar-archive-plugin xarchiver unzip sudo bash wget htop gnome-keyring xfce4-screenshooter-plugin ristretto gnome-font-viewer vlc audacious audacious-plugins firefox mixer mixertui nano

echo ""

echo "Enabling automount..."

echo ""

pkg install -y automount exfat-utils fusefs-exfat fusefs-ntfs fusefs-ext2 fusefs-hfsfuse fusefs-lkl fusefs-simple-mtpfs

echo ""

echo "Enabling basic services"

sysrc moused_enable="YES"
sysrc dbus_enable="YES"
sysrc hald_enable="YES"
sysrc slim_enable="YES"

echo ""

cd

touch .xinitrc

echo 'exec xfce4-session' >> .xinitrc

echo ""

echo ; read -p "Want to enable XFCE for a regular user? (yes/no): " X;

echo ""

if [ "$X" = "yes" ]
then
    echo ; read -p "For what user? " user;
    touch /usr/home/$user/.xinitrc
    echo 'exec xfce4-session' >> /usr/home/$user/.xinitrc
    echo ""
    echo "$user enabled"
else fi

echo ""

echo "Enabling Linux compat layer..."

echo ""

kldload linux.ko
sysrc linux_enable="YES"

echo ""

echo "Compiling latest Nvidia drivers..."

echo ""

cd /usr/ports/x11/nvidia-driver
make install clean BATCH=yes
cd /usr/ports/x11/nvidia-settings
make install clean BATCH=yes
cd /usr/ports/x11/nvidia-xconfig
make install clean BATCH=yes

echo 'nvidia-modeset_load="YES"' >> /boot/loader.conf

nvidia-xconfig

echo ""

echo "Latest Nvidia drivers compiled"

echo ""

echo "Optimizing system..."

echo ""

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

echo "Enabling additional system services..."

echo ""

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
sysrc sendmail_enable="NO"
sysrc sendmail_msp_queue_enable="NO"
sysrc sendmail_outbound_enable="NO"
sysrc sendmail_submit_enable="NO"
sysrc dumpdev="NO"
sysrc webcamd_enable="YES"

echo ""

echo "Updating CPU microcode..."

echo ""

pkg install -y devcpu-data
sysrc microcode_update_enable="YES"
service microcode_update start

echo ""

echo "Microcode updated"

echo ""

echo "Cleaning system..."

echo ""

pkg clean -y

echo ""

echo "Installation done"
echo "Please restart your system."
echo "BSD-XFCE by Wamphyre :)"

echo ""
