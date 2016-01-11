#!/bin/bash
# Nginx Onekey Install Shell For Centos
# Tested with Centos 6 32/64bit
# Script author <github-charisma@32mb.cn>
# Blog : http://blog.iplayloli.com
function install {
#1.Load config
	source ~/nginx_onekey_config
	mkdir -p "$install_temp"
	cd "$install_temp"
#2.Handmade Clean and Streamlined Debian VPS System
	case "$streamline" in
		yes)
			yum remove Deployment_Guide-en-US finger cups-libs cups ypbind -y
			yum remove bluez-libs desktop-file-utils ppp rp-pppoe wireless-tools irda-utils -y
			yum remove sendmail* samba* talk-server finger-server bind* xinetd -y
			yum remove nfs-utils nfs-utils-lib rdate fetchmail eject ksh mkbootdisk mtools-y
			yum remove syslinux tcsh startup-notification talk apmd rmt dump setserial portmap yp-tools -y
			;;
		*)
			echo "skiped!"
			;;
	esac
#3.Remove apache
yum remove httpd* -y
#4.Install nginx
	upgrade
#5.Set up nginx autostart
	cp /etc/rc.local /etc/rc.local_bak -f
	DAEMON="$install_path/sbin/nginx"
	cat /etc/rc.local|grep 'exit 0'
	if [ $? -eq 0 ]; then
		sed -i 's/\"exit 0\"/\#/g' /etc/rc.local
		sed -i 's/\#exit 0/\#/g' /etc/rc.local
		sed -i "s#exit 0#$DAEMON\nexit 0#" /etc/rc.local
	else
		echo "$DAEMON">>/etc/rc.local
	fi
}
function upgrade {
#1.Read Config
	source ~/nginx_onekey_config
#2.Prepare
	yum update -y
	yum install git gcc gcc-c++ make automake -y
	if [ ! $? -eq 0 ]; then
		yum install git gcc gcc-c++ make automake -y
	fi
	yum install git gcc gcc-c++ make automake -y
	if [ $? -eq 0 ]; then
		echo "git gcc gcc-c++ make automake installed"
	else
		yum install git gcc gcc-c++ make automake -y
	fi
	mkdir -p "$install_temp"
	cd "$install_temp"
#2.1.add user and group
	/usr/sbin/groupadd -f $n_group
	/usr/sbin/useradd -g $n_group $n_user
#2.2.Download and Unpack Nginx
	wget http://nginx.org/download/nginx-$nginx_ver.tar.gz || wget http://nginx.org/download/nginx-$nginx_ver.tar.gz
	tar -xzvf nginx-$nginx_ver.tar.gz || tar -xzvf nginx-$nginx_ver.tar.gz
#2.3.Download subs_filter
	git clone https://github.com/yaoweibin/ngx_http_substitutions_filter_module || git clone https://github.com/yaoweibin/ngx_http_substitutions_filter_module
#2.4 Other preparation
	case $complie_poz in
		yes)
#			Download and unpack PCRE
			wget $pcre_mirror/pcre-$pre_ver.tar.gz
			tar -xzvf pcre-$pcre_ver.tar.gz
#			Download and unpack OpenSSL
			wget $ossl_mirror/openssl-$ossl_ver.tar.gz
			tar -xzvf openssl-$ossl_ver.tar.gz
#			Download and unpack zLib
			wget $zlib_mirror/zlib-$zlib_ver.tar.gz
			tar -xzvf zlib-$zlib_ver.tar.gz
			cd nginx-$nginx_ver
			./configure --prefix=$install_path --conf-path=$conf_path --with-pcre=$install_temp/pcre-$pcre_ver --user=$n_user --group=$n_group --error-log-path=$log_path/error.log --http-log-path=$log_path/access.log --pid-path=/var/run/nginx/nginx.pid --lock-path=/var/lock/nginx.lock --with-ipv6 --with-http_ssl_module --with-openssl=$install_temp/openssl-$ossl_ver --with-http_stub_status_module --with-http_gzip_static_module --with-zlib=$install_temp/zlib-$zlib_ver --add-module=$install_temp/ngx_http_substitutions_filter_module
			;;
		*)
#			install pcre
			yum install pcre pcre-devel -y
			if [ $? -eq 0 ]; then
				echo "pcre pcre-devel installed"
			else
				yum install pcre pcre-devel -y 
			fi
#			install openssl zlib
			yum install zlib zlib-devel openssl openssl-devel -y 
			if [ $? -eq 0 ]; then
				echo "zlib zlib-devel openssl openssl-devel installed"
			else
				yum install zlib zlib-devel openssl openssl-devel -y
			fi
			cd "nginx-$nginx_ver"
			./configure --prefix=$install_path --conf-path=$conf_path --user=$n_user --group=$n_group --error-log-path=$log_path/error.log --http-log-path=$log_path/access.log --pid-path=/var/run/nginx/nginx.pid --lock-path=/var/lock/nginx.lock --with-pcre-jit --with-ipv6 --with-http_ssl_module --with-http_stub_status_module --with-http_gzip_static_module --with-http_realip_module --add-module=$install_temp/ngx_http_substitutions_filter_module
			;;
	esac
#3.Installation
	make && make install
	echo "nginx sbin:$install_path/sbin/nginx"
	$install_path/sbin/nginx -V
#4.Make dir and clean
	mkdir -p "$log_path"
	rm -rf "$install_temp"
}
case "$1" in
	install)
		install
		;;
	upgrade)
		upgrade
		;;
	*)
		echo "Nothing will be done!Exit now."
		exit 1;
		;;
esac
