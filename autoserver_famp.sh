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

pkg install -y php71 php71-hash php71-session php71-simplexml php71-pdo php71-pdo_mysql php71-zip php71-bcmath php71-posix php71-filter php71-xml php71-mysqli mod_php71 php71-mbstring php71-gd php71-json php71-mcrypt php71-zlib php71-curl

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

cp /usr/local/etc/apache24/httpd.conf /usr/local/etc/apache24/httpd.conf_bk;

service apache24 stop

rm -rf /usr/local/etc/apache24/httpd.conf

echo "
ServerRoot "/usr/local"

Listen 8080

#LoadModule mpm_event_module libexec/apache24/mod_mpm_event.so
LoadModule mpm_prefork_module libexec/apache24/mod_mpm_prefork.so
#LoadModule mpm_worker_module libexec/apache24/mod_mpm_worker.so
LoadModule authn_file_module libexec/apache24/mod_authn_file.so
#LoadModule authn_dbm_module libexec/apache24/mod_authn_dbm.so
#LoadModule authn_anon_module libexec/apache24/mod_authn_anon.so
#LoadModule authn_dbd_module libexec/apache24/mod_authn_dbd.so
#LoadModule authn_socache_module libexec/apache24/mod_authn_socache.so
LoadModule authn_core_module libexec/apache24/mod_authn_core.so
LoadModule authz_host_module libexec/apache24/mod_authz_host.so
LoadModule authz_groupfile_module libexec/apache24/mod_authz_groupfile.so
LoadModule authz_user_module libexec/apache24/mod_authz_user.so
#LoadModule authz_dbm_module libexec/apache24/mod_authz_dbm.so
#LoadModule authz_owner_module libexec/apache24/mod_authz_owner.so
#LoadModule authz_dbd_module libexec/apache24/mod_authz_dbd.so
LoadModule authz_core_module libexec/apache24/mod_authz_core.so
#LoadModule authnz_fcgi_module libexec/apache24/mod_authnz_fcgi.so
LoadModule access_compat_module libexec/apache24/mod_access_compat.so
LoadModule auth_basic_module libexec/apache24/mod_auth_basic.so
#LoadModule auth_form_module libexec/apache24/mod_auth_form.so
#LoadModule auth_digest_module libexec/apache24/mod_auth_digest.so
#LoadModule allowmethods_module libexec/apache24/mod_allowmethods.so
#LoadModule file_cache_module libexec/apache24/mod_file_cache.so
LoadModule cache_module libexec/apache24/mod_cache.so
LoadModule cache_disk_module libexec/apache24/mod_cache_disk.so
#LoadModule cache_socache_module libexec/apache24/mod_cache_socache.so
#LoadModule socache_shmcb_module libexec/apache24/mod_socache_shmcb.so
#LoadModule socache_dbm_module libexec/apache24/mod_socache_dbm.so
#LoadModule socache_memcache_module libexec/apache24/mod_socache_memcache.so
#LoadModule watchdog_module libexec/apache24/mod_watchdog.so
#LoadModule macro_module libexec/apache24/mod_macro.so
#LoadModule dbd_module libexec/apache24/mod_dbd.so
#LoadModule dumpio_module libexec/apache24/mod_dumpio.so
#LoadModule buffer_module libexec/apache24/mod_buffer.so
#LoadModule data_module libexec/apache24/mod_data.so
LoadModule ratelimit_module libexec/apache24/mod_ratelimit.so
LoadModule reqtimeout_module libexec/apache24/mod_reqtimeout.so
#LoadModule ext_filter_module libexec/apache24/mod_ext_filter.so
#LoadModule request_module libexec/apache24/mod_request.so
#LoadModule include_module libexec/apache24/mod_include.so
LoadModule filter_module libexec/apache24/mod_filter.so
#LoadModule reflector_module libexec/apache24/mod_reflector.so
#LoadModule substitute_module libexec/apache24/mod_substitute.so
#LoadModule sed_module libexec/apache24/mod_sed.so
#LoadModule charset_lite_module libexec/apache24/mod_charset_lite.so
LoadModule deflate_module libexec/apache24/mod_deflate.so
#LoadModule xml2enc_module libexec/apache24/mod_xml2enc.so
#LoadModule proxy_html_module libexec/apache24/mod_proxy_html.so
LoadModule mime_module libexec/apache24/mod_mime.so
LoadModule log_config_module libexec/apache24/mod_log_config.so
#LoadModule log_debug_module libexec/apache24/mod_log_debug.so
#LoadModule log_forensic_module libexec/apache24/mod_log_forensic.so
#LoadModule logio_module libexec/apache24/mod_logio.so
LoadModule env_module libexec/apache24/mod_env.so
#LoadModule mime_magic_module libexec/apache24/mod_mime_magic.so
#LoadModule cern_meta_module libexec/apache24/mod_cern_meta.so
#LoadModule expires_module libexec/apache24/mod_expires.so
LoadModule headers_module libexec/apache24/mod_headers.so
#LoadModule usertrack_module libexec/apache24/mod_usertrack.so
#LoadModule unique_id_module libexec/apache24/mod_unique_id.so
LoadModule setenvif_module libexec/apache24/mod_setenvif.so
LoadModule version_module libexec/apache24/mod_version.so
#LoadModule remoteip_module libexec/apache24/mod_remoteip.so
#LoadModule proxy_module libexec/apache24/mod_proxy.so
#LoadModule proxy_connect_module libexec/apache24/mod_proxy_connect.so
#LoadModule proxy_ftp_module libexec/apache24/mod_proxy_ftp.so
#LoadModule proxy_http_module libexec/apache24/mod_proxy_http.so
#LoadModule proxy_fcgi_module libexec/apache24/mod_proxy_fcgi.so
#LoadModule proxy_scgi_module libexec/apache24/mod_proxy_scgi.so
#LoadModule proxy_uwsgi_module libexec/apache24/mod_proxy_uwsgi.so
#LoadModule proxy_fdpass_module libexec/apache24/mod_proxy_fdpass.so
#LoadModule proxy_wstunnel_module libexec/apache24/mod_proxy_wstunnel.so
#LoadModule proxy_ajp_module libexec/apache24/mod_proxy_ajp.so
#LoadModule proxy_balancer_module libexec/apache24/mod_proxy_balancer.so
#LoadModule proxy_express_module libexec/apache24/mod_proxy_express.so
#LoadModule proxy_hcheck_module libexec/apache24/mod_proxy_hcheck.so
#LoadModule session_module libexec/apache24/mod_session.so
#LoadModule session_cookie_module libexec/apache24/mod_session_cookie.so
#LoadModule session_crypto_module libexec/apache24/mod_session_crypto.so
#LoadModule session_dbd_module libexec/apache24/mod_session_dbd.so
#LoadModule slotmem_shm_module libexec/apache24/mod_slotmem_shm.so
#LoadModule slotmem_plain_module libexec/apache24/mod_slotmem_plain.so
#LoadModule ssl_module libexec/apache24/mod_ssl.so
#LoadModule dialup_module libexec/apache24/mod_dialup.so
#LoadModule http2_module libexec/apache24/mod_http2.so
#LoadModule proxy_http2_module libexec/apache24/mod_proxy_http2.so
#LoadModule lbmethod_byrequests_module libexec/apache24/mod_lbmethod_byrequests.so
#LoadModule lbmethod_bytraffic_module libexec/apache24/mod_lbmethod_bytraffic.so
#LoadModule lbmethod_bybusyness_module libexec/apache24/mod_lbmethod_bybusyness.so
#LoadModule lbmethod_heartbeat_module libexec/apache24/mod_lbmethod_heartbeat.so
LoadModule unixd_module libexec/apache24/mod_unixd.so
#LoadModule heartbeat_module libexec/apache24/mod_heartbeat.so
#LoadModule heartmonitor_module libexec/apache24/mod_heartmonitor.so
#LoadModule dav_module libexec/apache24/mod_dav.so
LoadModule status_module libexec/apache24/mod_status.so
LoadModule autoindex_module libexec/apache24/mod_autoindex.so
#LoadModule asis_module libexec/apache24/mod_asis.so
#LoadModule info_module libexec/apache24/mod_info.so
<IfModule !mpm_prefork_module>
	#LoadModule cgid_module libexec/apache24/mod_cgid.so
</IfModule>
<IfModule mpm_prefork_module>
	#LoadModule cgi_module libexec/apache24/mod_cgi.so
</IfModule>
#LoadModule dav_fs_module libexec/apache24/mod_dav_fs.so
#LoadModule dav_lock_module libexec/apache24/mod_dav_lock.so
LoadModule vhost_alias_module libexec/apache24/mod_vhost_alias.so
#LoadModule negotiation_module libexec/apache24/mod_negotiation.so
LoadModule dir_module libexec/apache24/mod_dir.so
#LoadModule imagemap_module libexec/apache24/mod_imagemap.so
#LoadModule actions_module libexec/apache24/mod_actions.so
#LoadModule speling_module libexec/apache24/mod_speling.so
#LoadModule userdir_module libexec/apache24/mod_userdir.so
LoadModule alias_module libexec/apache24/mod_alias.so
LoadModule rewrite_module libexec/apache24/mod_rewrite.so
LoadModule php7_module        libexec/apache24/libphp7.so

IncludeOptional etc/apache24/modules.d/[0-9][0-9][0-9]_*.conf
 
<IfModule unixd_module>

User www
Group www

</IfModule>

ServerAdmin you@example.com

ServerName localhost:80

<Directory />
    AllowOverride none
    Require all denied
</Directory>

DocumentRoot "/usr/local/www/public_html"
<Directory "/usr/local/www/public_html">

    Options Indexes FollowSymLinks

    AllowOverride All
    
    Require all granted
</Directory>

<IfModule dir_module>
    DirectoryIndex index.php index.html
</IfModule>

<Files ".ht*">
    Require all denied
</Files>

ErrorLog "/var/log/apache-error.log"

# LogLevel: Control the number of messages logged to the error_log.
# Possible values include: debug, info, notice, warn, error, crit,
# alert, emerg.

LogLevel error

<IfModule log_config_module>

    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
    LogFormat "%h %l %u %t \"%r\" %>s %b" common

    <IfModule logio_module>

      LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio
    </IfModule>

    CustomLog "/var/log/apache-access.log" combined

</IfModule>

<IfModule alias_module>

    ScriptAlias /cgi-bin/ "/usr/local/www/apache24/cgi-bin/"

</IfModule>

<Directory "/usr/local/www/apache24/cgi-bin">
    AllowOverride None
    Options None
    Require all granted
</Directory>

<IfModule headers_module>
    RequestHeader unset Proxy early
</IfModule>

<IfModule mime_module>
    TypesConfig etc/apache24/mime.types
    AddType application/x-compress .Z
    AddType application/x-gzip .gz .tgz
</IfModule>

#ErrorDocument 500 "The server made a boo boo."
#ErrorDocument 404 /missing.html
#ErrorDocument 404 "/cgi-bin/missing_handler.pl"
#ErrorDocument 402 http://www.example.com/subscription_info.html

MaxRanges default

EnableMMAP on
EnableSendfile on

# Server-pool management (MPM specific)
#Include etc/apache24/extra/httpd-mpm.conf

# Multi-language error messages
#Include etc/apache24/extra/httpd-multilang-errordoc.conf

# Fancy directory listings
#Include etc/apache24/extra/httpd-autoindex.conf

# Language settings
#Include etc/apache24/extra/httpd-languages.conf

# User home directories
#Include etc/apache24/extra/httpd-userdir.conf

# Real-time info on requests and configuration
#Include etc/apache24/extra/httpd-info.conf

# Virtual hosts
#Include etc/apache24/extra/httpd-vhosts.conf

# Local access to the Apache HTTP Server Manual
#Include etc/apache24/extra/httpd-manual.conf

# Distributed authoring and versioning (WebDAV)
#Include etc/apache24/extra/httpd-dav.conf

# Various default settings
#Include etc/apache24/extra/httpd-default.conf

# Configure mod_proxy_html to understand HTML4/XHTML1
<IfModule proxy_html_module>
Include etc/apache24/extra/proxy-html.conf
</IfModule>

# Secure (SSL/TLS) connections
#Include etc/apache24/extra/httpd-ssl.conf
#
# Note: The following must must be present to support
#       starting without SSL on platforms with no /dev/random equivalent
#       but a statically compiled-in mod_ssl.
#
<IfModule ssl_module>
SSLRandomSeed startup builtin
SSLRandomSeed connect builtin
</IfModule>

Include etc/apache24/Includes/*.conf" >> /usr/local/etc/apache24/httpd.conf

sleep 3

echo ""

echo "Configurando PHP ini..."

mv /usr/local/etc/php.ini-production /usr/local/etc/php.ini-production_bk

touch /usr/local/etc/php.ini

echo "[PHP]

engine = On

short_open_tag = Off

precision = 14

output_buffering = 4096

zlib.output_compression = Off

implicit_flush = Off

unserialize_callback_func =

serialize_precision = -1

;open_basedir =

disable_functions = ini_set,phpinfo,proc_open,show_source,passthru,system,exec,shell,shell_exec,popen,pclose,proc_nice,proc_terminate,proc_get_status,proc_close,pfsockopen,leak,apache_child_terminate,posix_kill,posix_mkfifo,posix_setpgid,posix_setsid,posix_setuid,escapeshellcmd,escapeshellarg

disable_classes =

zend.enable_gc = On

expose_php = On

max_execution_time = 300

max_input_time = 300

max_input_nesting_level = 64

max_input_vars = 1000

memory_limit = 128M

error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT

display_errors = Off

display_startup_errors = Off

log_errors = On

log_errors_max_len = 1024

ignore_repeated_errors = Off

ignore_repeated_source = Off

report_memleaks = On

;report_zend_debug = 0

;track_errors = Off

;xmlrpc_errors = 0

;xmlrpc_error_number = 0

html_errors = On

;docref_root = "/phpmanual/"

;docref_ext = .html

;error_prepend_string = "<span style='color: #ff0000'>"

;error_append_string = "</span>"

variables_order = "GPCS"

request_order = "GP"

register_argc_argv = Off

auto_globals_jit = On

;enable_post_data_reading = Off

post_max_size = 55M

auto_prepend_file =

auto_append_file =

default_mimetype = "text/html"

default_charset = "UTF-8"

doc_root =

user_dir =

enable_dl = Off

file_uploads = On

upload_max_filesize = 55M

max_file_uploads = 20

allow_url_fopen = On

allow_url_include = Off

default_socket_timeout = 60

cli_server.color = On

date.timezone = Europe/Paris	

pdo_mysql.default_socket=

;phar.readonly = On

;phar.require_hash = On

;phar.cache_list =

[mail function]

SMTP = localhost

smtp_port = 25

; For Win32 only.
; http://php.net/sendmail-from
;sendmail_from = me@example.com

mail.add_x_header = Off

odbc.allow_persistent = On

odbc.check_persistent = On

odbc.max_persistent = -1

odbc.max_links = -1

odbc.defaultlrl = 4096

odbc.defaultbinmode = 1

ibase.allow_persistent = 1

ibase.max_persistent = -1

ibase.max_links = -1

;ibase.default_db =

;ibase.default_user =

;ibase.default_password =

;ibase.default_charset =

ibase.timestampformat = "%Y-%m-%d %H:%M:%S"

ibase.dateformat = "%Y-%m-%d"

ibase.timeformat = "%H:%M:%S"

mysqli.max_persistent = -1

;mysqli.allow_local_infile = On

mysqli.allow_persistent = On

mysqli.max_links = -1

mysqli.default_port = 3306

mysqli.default_socket =

mysqli.default_host =

mysqli.default_user =

mysqli.default_pw =

mysqli.reconnect = Off

mysqlnd.collect_statistics = On

mysqlnd.collect_memory_statistics = Off

;mysqlnd.debug =

;mysqlnd.log_mask = 0

;mysqlnd.mempool_default_size = 16000

;mysqlnd.net_cmd_buffer_size = 2048

;mysqlnd.net_read_buffer_size = 32768

;mysqlnd.net_read_timeout = 31536000

;mysqlnd.sha256_server_public_key =

;oci8.privileged_connect = Off

;oci8.max_persistent = -1

;oci8.persistent_timeout = -1

;oci8.ping_interval = 60

;oci8.connection_class =

;oci8.events = Off

;oci8.statement_cache_size = 20

;oci8.default_prefetch = 100

;oci8.old_oci_close_semantics = Off

pgsql.auto_reset_persistent = Off

pgsql.max_persistent = -1

pgsql.max_links = -1

pgsql.ignore_notice = 0

pgsql.log_notice = 0

bcmath.scale = 0

;browscap = extra/browscap.ini

session.save_handler = files

session.use_strict_mode = 0

session.use_cookies = 1

;session.cookie_secure =

session.use_only_cookies = 1

session.name = PHPSESSID

session.auto_start = 0

session.cookie_lifetime = 0

session.cookie_path = /

session.cookie_domain =

session.cookie_httponly =

session.cookie_samesite =

session.serialize_handler = php

session.gc_probability = 1

session.gc_divisor = 1000

session.gc_maxlifetime = 1440

session.referer_check =

session.cache_limiter = nocache

session.cache_expire = 180

session.use_trans_sid = 0

session.sid_length = 26

session.trans_sid_tags = "a=href,area=href,frame=src,form="

;session.trans_sid_hosts=""

session.sid_bits_per_character = 5

;session.upload_progress.enabled = On

;session.upload_progress.cleanup = On

;session.upload_progress.prefix = "upload_progress_"

;session.upload_progress.name = "PHP_SESSION_UPLOAD_PROGRESS"

;session.upload_progress.freq =  "1%"

;session.upload_progress.min_freq = "1"

;session.lazy_write = On

zend.assertions = -1

;assert.active = On

;assert.exception = On

;assert.warning = On

;assert.bail = Off

;assert.callback = 0

;assert.quiet_eval = 0

;com.typelib_file =

;com.allow_dcom = true

;com.autoregister_typelib = true

;com.autoregister_casesensitive = false

;com.autoregister_verbose = true

;com.code_page=

;mbstring.language = Japanese

;mbstring.internal_encoding =

;mbstring.http_input =

;mbstring.http_output =

;mbstring.encoding_translation = Off

;mbstring.detect_order = auto

;mbstring.substitute_character = none

;mbstring.func_overload = 0

;mbstring.strict_detection = On

;mbstring.http_output_conv_mimetype=

;gd.jpeg_ignore_warning = 1

;exif.encode_unicode = ISO-8859-15

;exif.decode_unicode_motorola = UCS-2BE

;exif.decode_unicode_intel    = UCS-2LE

;exif.encode_jis =

;exif.decode_jis_motorola = JIS

;exif.decode_jis_intel    = JIS

tidy.clean_output = Off

soap.wsdl_cache_enabled=1

soap.wsdl_cache_dir="/tmp"

soap.wsdl_cache_ttl=86400

soap.wsdl_cache_limit = 5

;sysvshm.init_mem = 10000

ldap.max_links = -1

;dba.default_handler=

;opcache.enable=1

;opcache.enable_cli=0

;opcache.memory_consumption=128

;opcache.interned_strings_buffer=8

;opcache.max_accelerated_files=10000

;opcache.max_wasted_percentage=5

;opcache.use_cwd=1

;opcache.validate_timestamps=1

;opcache.revalidate_freq=2

;opcache.revalidate_path=0

;opcache.save_comments=1

;opcache.enable_file_override=0

;opcache.optimization_level=0x7FFFBFFF

;opcache.dups_fix=0

;opcache.blacklist_filename=

;opcache.max_file_size=0

;opcache.consistency_checks=0

;opcache.force_restart_timeout=180

;opcache.error_log=

;opcache.log_verbosity_level=1

;opcache.preferred_memory_model=

;opcache.protect_memory=0

;opcache.restrict_api=

;opcache.mmap_base=

;opcache.file_cache=

;opcache.file_cache_only=0

;opcache.file_cache_consistency_checks=1

;opcache.file_cache_fallback=1

;opcache.huge_code_pages=1

;opcache.validate_permission=0

;opcache.validate_root=0

;opcache.opt_debug_level=0

;curl.cainfo =

;openssl.cafile=

;openssl.capath=

; Local Variables:
; tab-width: 4
; End:" >> /usr/local/etc/php.ini

mkdir /usr/local/www/public_html

service apache24 restart

echo ""

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

then cd /usr/local/www/public_html/;

fetch https://files.phpmyadmin.net/phpMyAdmin/4.8.3/phpMyAdmin-4.8.3-all-languages.zip;

unzip phpMyAdmin-4.8.3-all-languages.zip && rm -rf *.zip;

mv phpMyAdmin-4.8.3-all-languages phpmyadmin;

cd;

else echo "No se instalará phpmyadmin" 

fi

echo ; read -p "¿Quieres instalar el panel de control FROXLOR?: (si/no) " FROXLOR;

if [ "$FROXLOR" = "si" ]

then cd /usr/local/www/public_html/;

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
chown -R www:www /usr/local/www/public_html/
chown -R www:www /usr/local/www/public_html/*

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
inbound_tcp_services = "{80, 8080, " $ssh_port " }"
#inbound_udp_services = "{dhcpv6-client,openvpn}"

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
