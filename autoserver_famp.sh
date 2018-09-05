#!/bin/bash

echo ""

echo "=====AUTOSERVER FAMP====="

echo "----------------------by Wamphyre"

echo ""

sleep 3

echo "Actualizando paquetes...";

echo ""

pkg update && pkg upgrade -y ;

echo ""

echo "Paquetes actualizados" 

echo ""

echo "Instalando APACHE, MARIADB, PHP71, VARNISH"

echo ""

sleep 2

pkg install -y apache24

pkg install -y php71 php71-session php71-pdo php71-pdo_mysql php71-zip php71-bcmath php71-posix php71-filter php71-xml php71-mysqli mod_php71 php71-mbstring php71-gd php71-json php71-mcrypt php71-zlib php71-curl

pkg install -y mariadb102-client mariadb102-server

pkg install -y varnish5

echo ""

echo "STACK INSTALADO"

echo ""

echo "Configurando Stack..."

echo ""

sysrc apache24_enable="yes"

service apache24 start

sleep 3

echo '<IfModule dir_module>
DirectoryIndex index.php index.html
<FilesMatch "\.php$">
SetHandler application/x-httpd-php
</FilesMatch>
<FilesMatch "\.phps$">
SetHandler application/x-httpd-php-source
</FilesMatch>
</IfModule>' >> /usr/local/etc/apache24/Includes/php.conf

sleep 2

sed '52 s/Listen 80/Listen 8080/g' /usr/local/etc/apache24/httpd.conf

sleep 3

service apache24 restart

sysrc mysql_enable="YES"

sysrc mysql_args="--bind-address=127.0.0.1"

service mysql-server start

sleep 10

/usr/local/bin/mysql_secure_installation

sysrc varnishd_enable=YES

sysrc varnishd_listen=":80"

sysrc varnishd_backend="localhost:8080"

sysrc varnishd_storage="malloc,512M"

sysrc varnishd_admin=":8081"

sleep 3

echo "Configuración base completada"

echo ""

echo ; read -p "¿Quieres instalar phpmyadmin?: (si/no) " PHPMYADMIN;

if [ "$PHPMYADMIN" = "si" ] 

then cd /usr/local/www/apache24/data/;

fetch https://files.phpmyadmin.net/phpMyAdmin/4.8.3/phpMyAdmin-4.8.3-all-languages.zip;

unzip phpMyAdmin-4.8.3-all-languages.zip && rm -rf *.zip;

mv phpMyAdmin-4.8.3-all-languages phpmyadmin;

cd;

else echo "No se instalará phpmyadmin" 

fi

echo ; read -p "¿Quieres instalar el panel de control FROXLOR?: (si/no) " FROXLOR;

if [ "$FROXLOR" = "si" ]

then cd /usr/local/www/apache24/data/;

fetch https://files.froxlor.org/releases/froxlor-latest.tar.gz;

tar -xvf froxlor-latest.tar.gz && rm -rf *.tar.gz;

cd;

else echo "No se instalará Froxlor" 

fi

echo "Aplicando hardening y tuning de rendimiento"

echo ""

mv /etc/sysctl.conf /etc/sysctl.conf.bk
echo 'vfs.usermount=1' >> /etc/sysctl.conf
echo 'vfs.vmiodirenable=0' >> /etc/sysctl.conf
echo 'vfs.read_max=4' >> /etc/sysctl.conf
echo 'kern.ipc.shmmax=67108864' >> /etc/sysctl.conf
echo 'kern.ipc.shmall=32768' >> /etc/sysctl.conf
echo 'kern.ipc.somaxconn=256' >> /etc/sysctl.conf
echo 'kern.ipc.shm_use_phys=1' >> /etc/sysctl.conf
echo 'kern.ipc.somaxconn=32' >> /etc/sysctl.conf
echo 'kern.maxvnodes=60000' >> /etc/sysctl.conf
echo 'kern.coredump=0' >> /etc/sysctl.conf
echo 'kern.sched.preempt_thresh=224' >> /etc/sysctl.conf
echo 'kern.sched.slice=3' >> /etc/sysctl.conf
echo 'kern.maxfiles=10000' >> /etc/sysctl.conf
echo 'hw.snd.feeder_rate_quality=3' >> /etc/sysctl.conf
echo 'hw.snd.maxautovchans=32' >> /etc/sysctl.conf
echo 'vfs.lorunningspace=1048576' >> /etc/sysctl.conf
echo 'vfs.hirunningspace=5242880' >> /etc/sysctl.conf
echo 'kern.ipc.shm_allow_removed=1' >> /etc/sysctl.conf
echo 'snd_hda="YES"' >> /boot/loader.conf
echo 'mixer_enable="YES"' >> /boot/loader.conf
echo 'hint.pcm.0.buffersize=65536' >> /boot/loader.conf
echo 'hint.pcm.1.buffersize=65536' >> /boot/loader.conf
echo 'hw.snd.feeder_buffersize=65536' >> /boot/loader.conf
echo 'hw.snd.latency=0' >> /boot/loader.conf
echo 'hint.pcm.0.eq="1"' >> /boot/loader.conf
echo 'hint.pcm.1.eq="1"' >> /boot/loader.conf
echo 'hint.pcm.2.eq="1"' >> /boot/loader.conf
echo 'hint.pcm.3.eq="1"' >> /boot/loader.conf
echo 'hint.pcm.4.eq="1"' >> /boot/loader.conf
echo 'hint.pcm.5.eq="1"' >> /boot/loader.conf
echo 'hint.pcm.6.eq="1"' >> /boot/loader.conf
echo 'hint.pcm.7.eq="1"' >> /boot/loader.conf
echo 'hint.pcm.8.eq="1"' >> /boot/loader.conf
echo 'hint.pcm.9.eq="1"' >> /boot/loader.conf
echo 'hw.snd.vpc_autoreset=0' >> /boot/loader.conf
echo 'hw.syscons.bell=0' >> /boot/loader.conf
echo 'hw.usb.no_pf=1' >> /boot/loader.conf
echo 'hw.usb.no_boot_wait=0' >> /boot/loader.conf
echo 'hw.usb.no_shutdown_wait=1' >> /boot/loader.conf
echo 'hw.psm.synaptics_support=1' >> /boot/loader.conf
echo 'kern.maxfiles="25000"' >> /boot/loader.conf
echo 'kern.maxusers=16' >> /boot/loader.conf
echo 'kern.cam.scsi_delay=10000' >> /boot/loader.conf

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

echo 'kern.elf64.nxstack=1' >> /etc/sysctl.conf
echo 'security.bsd.map_at_zero=0' >> /etc/sysctl.conf
echo 'security.bsd.see_other_uids=0' >> /etc/sysctl.conf
echo 'security.bsd.see_other_gids=0' >> /etc/sysctl.conf
echo 'security.bsd.unprivileged_read_msgbuf=0' >> /etc/sysctl.conf
echo 'security.bsd.unprivileged_proc_debug=0' >> /etc/sysctl.conf
echo 'kern.randompid=9800' >> /etc/sysctl.conf
echo 'security.bsd.stack_guard_page=1' >> /etc/sysctl.conf
echo 'net.inet.udp.blackhole=1' >> /etc/sysctl.conf
echo 'net.inet.tcp.blackhole=2' >> /etc/sysctl.conf
echo 'net.inet.ip.random_id=1' >> /etc/sysctl.conf
chown -R www:www /usr/local/www/apache24/data/
chown -R www:www /usr/local/www/apache24/data/*

echo ""

echo "Optimizando stack de red de FreeBSD"

echo ""

echo 'kern.ipc.soacceptqueue=1024' >> /etc/sysctl.conf
echo 'kern.ipc.maxsockbuf=8388608' >> /etc/sysctl.conf
echo 'net.inet.tcp.sendspace=262144' >> /etc/sysctl.conf
echo 'net.inet.tcp.recvspace=262144' >> /etc/sysctl.conf
echo 'net.inet.tcp.sendbuf_max=16777216' >> /etc/sysctl.conf
echo 'net.inet.tcp.recvbuf_max=16777216' >> /etc/sysctl.conf
echo 'net.inet.tcp.sendbuf_inc=32768' >> /etc/sysctl.conf
echo 'net.inet.tcp.recvbuf_inc=65536' >> /etc/sysctl.conf
echo 'net.inet.raw.maxdgram=16384' >> /etc/sysctl.conf
echo 'net.inet.raw.recvspace=16384' >> /etc/sysctl.conf
echo 'net.inet.tcp.abc_l_var=44' >> /etc/sysctl.conf
echo 'net.inet.tcp.initcwnd_segments=44' >> /etc/sysctl.conf
echo 'net.inet.tcp.mssdflt=1448' >> /etc/sysctl.conf
echo 'net.inet.tcp.minmss=524' >> /etc/sysctl.conf
echo 'net.inet.tcp.cc.algorithm=htcp' >> /etc/sysctl.conf
echo 'net.inet.tcp.cc.htcp.adaptive_backoff=1' >> /etc/sysctl.conf
echo 'net.inet.tcp.cc.htcp.rtt_scaling=1' >> /etc/sysctl.conf
echo 'net.inet.tcp.rfc6675_pipe=1' >> /etc/sysctl.conf
echo 'net.inet.tcp.syncookies=0' >> /etc/sysctl.conf
echo 'net.inet.tcp.nolocaltimewait=1' >> /etc/sysctl.conf
echo 'net.inet.tcp.tso=0' >> /etc/sysctl.conf
echo 'net.inet.ip.intr_queue_maxlen=2048' >> /etc/sysctl.conf
echo 'net.route.netisr_maxqlen=2048' >> /etc/sysctl.conf
echo 'dev.igb.0.fc=0' >> /etc/sysctl.conf
echo 'dev.igb.1.fc=0' >> /etc/sysctl.conf
echo 'aio_load="yes"' >> /boot/loader.conf
echo 'cc_htcp_load="YES"' >> /boot/loader.conf
echo 'accf_http_load="YES"' >> /boot/loader.conf
echo 'accf_data_load="YES"' >> /boot/loader.conf
echo 'accf_dns_load="YES"' >> /boot/loader.conf
echo 'net.inet.tcp.hostcache.cachelimit="0"' >> /boot/loader.conf
echo 'net.link.ifqmaxlen="2048"' >> /boot/loader.conf
echo 'net.inet.tcp.soreceive_stream="1"' >> /boot/loader.conf
echo 'hw.igb.rx_process_limit="-1"' >> /boot/loader.conf
echo 'ahci_load="YES"' >> /boot/loader.conf
echo 'coretemp_load="YES"' >> /boot/loader.conf
echo 'tmpfs_load="YES"' >> /boot/loader.conf
echo 'if_igb_load="YES"' >> /boot/loader.conf

echo ""

echo "Actualizando microcódigo de la CPU"

echo ""

pkg install -y devcpu-data

sysrc microcode_update_enable="YES"

service microcode_update start

echo ""

echo "Microcódigo actualizado"

echo ""

echo "Añadiendo y configurando reglas estrictas para el Firewall PF"

echo ""

touch /etc/pf.conf

echo "Mostrando interfaces de red disponibles"

echo ""

ifconfig | grep :

echo ""

echo ; read -p "¿Para qué interfaz quieres configurar las reglas?: " INTERFAZ;

echo ""

echo '# the external network interface to the internet
ext_if="$INTERFAZ"

# port on which sshd is running
ssh_port = "22"

# allowed inbound ports (services hosted by this machine)
inbound_tcp_services = "{80, 8080, 443, " $ssh_port " }"
inbound_udp_services = "{dhcpv6-client,openvpn}"

# politely send TCP RST for blocked packets. The alternative is
# "set block-policy drop", which will cause clients to wait for a timeout
# before giving up.
set block-policy return

# log only on the external interface
set loginterface $ext_if

# skip all filtering on localhost
set skip on lo

# reassemble all fragmented packets before filtering them
scrub in on $ext_if all fragment reassemble

# block forged client IPs (such as private addresses from WAN interface)
antispoof for $ext_if

# default behavior: block all traffic
block all

# allow all icmp traffic (like ping)
pass quick on $ext_if proto icmp
pass quick on $ext_if proto icmp6

# allow incoming traffic to services hosted by this machine
pass in quick on $ext_if proto tcp to port $inbound_tcp_services
pass in quick on $ext_if proto udp to port $inbound_udp_services

# allow all outgoing traffic
pass out quick on $ext_if' >> /etc/pf.conf

echo ""

echo "Reglas añadidas al firewall y configuradas para la interfaz $INTERFAZ"

echo ""

echo "Limpiando sistema..."

echo ""

pkg clean -y && pkg autoremove -y

echo ""

echo "Instalación finalizada. Reinicia el servidor"
