#!/bin/bash

clear

echo "=====AUTOSERVER====="

echo "----------------------by Wamphyre"

echo ""

sleep 3

echo "Actualizando paquetes...";

echo ""

pkg update && pkg upgrade -y ;

echo ""

echo "Paquetes actualizados" 

echo ""

echo "INSTALANDO VARNISH + NGINX + CERTBOT + PHP73 + MARIADB"

pkg install -y php73 php73-mysqli php73-session php73-xml php73-hash php73-ftp php73-curl php73-tokenizer php73-zlib php73-zip php73-filter php73-gd php73-openssl

pkg install -y mariadb103-client mariadb103-server

pkg install -y py36-certbot-nginx

pkg install -y py36-salt

pkg install -y nano htop git libtool automake autoconf curl geoip

pkg install -y nginx

pkg install -y varnish6

echo "Configurando Stack..."

sysrc nginx_enable="YES"

sysrc php_fpm_enable="YES"

sysrc varnishd_enable=YES

sysrc varnishd_listen=":80"

sysrc varnishd_backend="localhost:8080"

sysrc varnishd_storage="malloc,512M"

sysrc varnishd_admin=":8081"

mv /usr/local/etc/nginx/nginx.conf /usr/local/etc/nginx/nginx.conf_bk

cd /usr/local/etc/nginx/ && fetch https://raw.githubusercontent.com/Wamphyre/AutoTools/master/nginx.conf

mkdir conf.d

touch /usr/local/etc/nginx/conf.d/default_vhost.conf && cd /usr/local/etc/nginx/conf.d/

DOMINIO=$(hostname)

echo "

server {
listen 8080;
listen [::]:8080;

server_name $DOMINIO;

root /usr/local/www/public_html;
index index.php index.html;
    
    # DNS resolver - you may want to change it to some other provider,
    # e.g. OpenDNS: 208.67.222.222
    # or Google: 8.8.8.8
    # (9.9.9.9 is https://quad9.net )
    resolver                   1.1.1.1;
    # allow POSTs to static pages
    error_page                 405    =200 \$uri;
    access_log                 /var/log/nginx/$DOMINIO-access.log;
    error_log                  /var/log/nginx/$DOMINIO-error.log;

    # gzip compression

gzip on;
gzip_vary on;
gzip_min_length 1024;
gzip_proxied expired no-cache no-store private auth;
gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml;
gzip_disable "MSIE [1-6]\.";

    # no logging for favicon

    location ~ favicon.ico\$ {
        access_log off;
    }

     location ~ \.php$ {
        root	/usr/local/www/public_html;
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;
        fastcgi_param SCRIPT_FILENAME $request_filename;    
        include        fastcgi_params;
        	}

    # expires of assets (per extension)

    location ~ .(jpe?g|gif|png|webp|ico|css|js|zip|tgz|gz|rar|bz2|7z|tar|pdf|txt|mp4|m4v|webm|flv|wav|swf)\$ {
        if (\$args ~ [0-9]+) {
            expires 30d;
        } 
    }

    # expires of assets (per path)

    location ~ ^/(css|js|img|files) {
        if (\$args ~ [0-9]+) {
            expires 30d;
        } 
    }
}
" >> default_vhost.conf

service nginx start

service varnishd start

mv /usr/local/etc/php.ini-production /usr/local/etc/php.ini-production_bk

cd /usr/local/etc/ && fetch https://raw.githubusercontent.com/Wamphyre/AutoTools/master/php.ini

mkdir /usr/local/www/public_html

cd /usr/local/www/public_html

chown -R www:www /usr/local/www/public_html/

echo ""

sysrc mysql_enable="YES"

sysrc mysql_args="--bind-address=127.0.0.1"

service mysql-server start

sleep 5

/usr/local/bin/mysql_secure_installation

echo ; read -p "¿Quieres instalar phpmyadmin?: (si/no) " PHPMYADMIN;

if [ "$PHPMYADMIN" = "si" ] 

then cd /usr/local/www/public_html/;

pkg install -y phpMyAdmin-php73

ln -s /usr/local/www/phpMyAdmin/ /usr/local/www/public_html/phpmyadmin

service nginx restart

service php-fpm restart

cd;

else echo "No se instalará phpmyadmin" 

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
echo 'hw.snd.feeder_rate_quality=3' >> /etc/sysctl.conf
echo 'hw.snd.maxautovchans=32' >> /etc/sysctl.conf
echo 'vfs.lorunningspace=1048576' >> /etc/sysctl.conf
echo 'vfs.hirunningspace=5242880' >> /etc/sysctl.conf
echo 'kern.ipc.shm_allow_removed=1' >> /etc/sysctl.conf
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
sysrc sendmail_enable="YES"
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
ext_if="'$INTERFAZ'"
# port on which sshd is running
ssh_port = "22"
# allowed inbound ports (services hosted by this machine)
inbound_tcp_services = "{80, 8080, 443, 21, 25," $ssh_port " }"
inbound_udp_services = "{80, 8080, 443,}"
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
#pass in quick on $ext_if proto udp to port $inbound_udp_services
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
