#!/bin/bash

clear

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

echo "INSTALANDO NGINX + BROTLI + PHP-FPM + MODSECURITY + PHP72 + MARIADB"

pkg install -y php72 php72-mysqli php72-session php72-xml php72-hash php72-ftp php72-curl php72-tokenizer php72-zlib php72-zip php72-filter php72-gd php72-openssl

pkg install -y mariadb102-client mariadb102-server

pkg install -y py36-certbot-nginx

pkg install -y py36-salt

pkg install -y nano htop git libtool automake autoconf curl libnghttp2 apache24 geoip

echo "Configurando Stack..."

mkdir /root/build && cd /root/build

fetch https://nginx.org/download/nginx-1.14.0.tar.gz 

git clone https://github.com/SpiderLabs/ModSecurity

git clone https://github.com/SpiderLabs/owasp-modsecurity-crs

git clone https://github.com/google/ngx_brotli

cd ngx_brotli && git submodule update --init && cd ..

tar -zxf nginx-1.14.0.tar.gz && rm -f nginx*tar.gz

/usr/local/bin/geoipupdate.sh

cd ModSecurity

sh autogen.sh

./configure --enable-standalone-module

make

cd ../nginx-*/

./configure --add-module=../ngx_brotli/ --add-module=../ModSecurity/nginx/modsecurity/ --prefix=/usr/local/etc/nginx --with-cc-opt='-I /usr/local/include' --with-ld-opt='-L /usr/local/lib' --conf-path=/usr/local/etc/nginx/nginx.conf --sbin-path=/usr/local/sbin/nginx --pid-path=/var/run/nginx.pid --error-log-path=/var/log/nginx/error.log --user=www --group=www --modules-path=/usr/local/libexec/nginx --with-file-aio --http-client-body-temp-path=/var/tmp/nginx/client_body_temp --http-fastcgi-temp-path=/var/tmp/nginx/fastcgi_temp --http-proxy-temp-path=/var/tmp/nginx/proxy_temp --http-scgi-temp-path=/var/tmp/nginx/scgi_temp --http-uwsgi-temp-path=/var/tmp/nginx/uwsgi_temp --http-log-path=/var/log/nginx/access.log --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gzip_static_module --with-http_gunzip_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_stub_status_module --with-http_sub_module --with-pcre --with-http_v2_module --with-stream=dynamic --with-stream_ssl_module --with-stream_ssl_preread_module --with-threads --with-mail=dynamic --without-mail_imap_module --without-mail_pop3_module --without-mail_smtp_module --with-mail_ssl_module --with-http_ssl_module --with-http_geoip_module=dynamic

make && make install

cd ..

mkdir -p /usr/local/etc/rc.d

fetch -o /usr/local/etc/rc.d/nginx https://malcont.net/wp-content/uploads/2018/01/nginx_freebsd_rcd_script

chmod 555 /usr/local/etc/rc.d

chmod 555 /usr/local/etc/rc.d/nginx

sysrc nginx_enable="YES"

cp owasp-modsecurity-crs/rules/*data /usr/local/etc/nginx/

cp ModSecurity/unicode.mapping /usr/local/etc/nginx/

cat owasp-modsecurity-crs/crs-setup.conf.example owasp-modsecurity-crs/rules/*conf > /usr/local/etc/nginx/modsecurity.conf

mkdir -p /usr/local/etc/nginx/conf.d /var/run/modsecurity

chmod 600 /usr/local/etc/nginx/conf.d /var/run/modsecurity

mv /usr/local/etc/nginx/nginx.conf /usr/local/etc/nginx/nginx.conf_bk

cd /usr/local/etc/nginx/ && fetch https://raw.githubusercontent.com/Wamphyre/AutoTools/master/nginx.conf

fetch https://raw.githubusercontent.com/Wamphyre/AutoTools/master/compression.conf

fetch https://raw.githubusercontent.com/Wamphyre/AutoTools/master/modsecurity.conf

touch /usr/local/etc/nginx/conf.d/default_vhost.conf && cd /usr/local/etc/nginx/conf.d/

DOMINIO=$(hostname)

echo " upstream php {
    server  unix:/var/run/php-wordpress.sock;
}

# HTTP (port 80) default server used only to redirect all requests to HTTPS version
server {
    # listening socket that will bind to port 80 on all available IPv4 addresses
    listen                     80 default_server;

    # listening socket that will bind to port 80 on all available IPv6 addresses
    listen                     [::]:80 default_server;

    # HTTP redirection to HTTPS
    return                     301 https://\$host\$request_uri;
}


# HTTPS (port 443) server - our website
server {
    # listening socket that will bind to port 443 on all available IPv4 addresses
    listen                     443 ssl http2;

    # listening socket that will bind to port 443 on all available IPv6 addresses
    listen                     [::]:443 ssl;

    # brotli and gzip compression configuration
    include                    compression.conf;

    root                       /usr/local/www/public_html;
    index                      index.php;

    # change this to your domain name (domain.com) or host name (blog.domain.com)
    server_name                $DOMINIO;   

    # handle weird requests in a rude manner
    if (\$host != \$server_name) {
         return                418;
    }

    # DNS resolver - you may want to change it to some other provider,
    # e.g. OpenDNS: 208.67.222.222
    # or Google: 8.8.8.8
    # (9.9.9.9 is https://quad9.net )
    resolver                   1.1.1.1;

    # allow POSTs to static pages
    error_page                 405    =200 \$uri;

    access_log                 /var/log/nginx/$DOMINIO-access.log;
    error_log                  /var/log/nginx/$DOMINIO-error.log;

    location / {
        ModSecurityEnabled     on;
        ModSecurityConfig      modsecurity.conf;
        # permalinks
        try_files              \$uri \$uri/ /index.php?\$args;
        location /wp-admin {
            ModSecurityEnabled          off;
            # admin-ajax.php and load-styles.php under wp-admin are allowed
            location ~ /wp-admin/(admin-ajax|load-styles)\.php {
                fastcgi_pass            php;
                include                 fastcgi.conf;
            }
        }
        
        }
        # deny access to xmlrpc.php which allows brute-forcing at a higher rates
        # than wp-login.php; this may break some functionality, like WordPress
        # iOS/Android app posting 
        location ~* /xmlrpc\.php {
            deny                        all;
        }
        # cache binary and SVG files for one month, don't log these requests
        location ~* \.(eot|gif|ico|jpg|png|jpeg|otf|pdf|swf|ttf|woff|woff2|mp4|svg)$ {
            expires                     1M;
            add_header                  Cache-Control public;
            access_log                  off;
        }

        # don't log requests to robots.txt and ads.txt
        location ~ /(robots|ads)\.txt {
            allow                       all;
            log_not_found               off;
            access_log                  off;
        }
        # handle PHP scripts
        location ~ .php$ {
	    fastcgi_pass                php;
            fastcgi_index               index.php;
            include                     fastcgi.conf;
        }
    }
" >> default_vhost.conf

service nginx start

mv /usr/local/etc/php.ini-production /usr/local/etc/php.ini-production_bk

cd /usr/local/etc/ && fetch https://raw.githubusercontent.com/Wamphyre/AutoTools/master/php.ini

mv /usr/local/etc/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/www.conf_bk

cd /usr/local/etc/php-fpm.d/ && fetch https://raw.githubusercontent.com/Wamphyre/AutoTools/master/www.conf

sysrc php_fpm_enable=YES

service php-fpm start

mkdir /usr/local/www/public_html

cd /usr/local/www/public_html

chown -R www:www /usr/local/www/public_html/

touch index.html

echo "FREEBSD WEB SERVER TESTING!! OK!" >> index.html

echo ""

sysrc mysql_enable="YES"

sysrc mysql_args="--bind-address=127.0.0.1"

service mysql-server start

sleep 10

/usr/local/bin/mysql_secure_installation

echo ; read -p "¿Quieres instalar phpmyadmin?: (si/no) " PHPMYADMIN;

if [ "$PHPMYADMIN" = "si" ] 

then cd /usr/local/www/public_html/;

fetch https://files.phpmyadmin.net/phpMyAdmin/4.8.3/phpMyAdmin-4.8.3-all-languages.zip;

unzip phpMyAdmin-4.8.3-all-languages.zip && rm -rf *.zip;

mv phpMyAdmin-4.8.3-all-languages phpmyadmin;

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
echo 'kern.maxfiles=10000' >> /etc/sysctl.conf
echo 'hw.snd.feeder_rate_quality=3' >> /etc/sysctl.conf
echo 'hw.snd.maxautovchans=32' >> /etc/sysctl.conf
echo 'vfs.lorunningspace=1048576' >> /etc/sysctl.conf
echo 'vfs.hirunningspace=5242880' >> /etc/sysctl.conf
echo 'kern.ipc.shm_allow_removed=1' >> /etc/sysctl.conf
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
inbound_tcp_services = "{80, 443, 21, 25," $ssh_port " }"
inbound_udp_services = "{80, 443,}"
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

pkg delete -f -y autoconf\* automake\* apache24\*

echo ""

echo "Instalación finalizada. Reinicia el servidor"
