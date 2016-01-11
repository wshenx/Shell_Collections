#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
clear
echo "
#========================================================================
# 			Nginx OneKey Install Shell
# Version :		0.1 alpha 5
# Script author :	Charisma<github-charisma@32mb.cn>
# Blog :		http://blog.iplayloli.com
# System Required :	Centos/Debian/Ubuntu
# Project url :		https://github.com/Shell_Collections/Nginx_OneKey
#========================================================================
"
function install {
#1.root access check
	rootness
#2.Choose system
	echo -n "Select which you want:
	1.Install for Debian/Ubuntu
	2.Install for Centos
Your choice:"
	read -r key
	case "$key" in
		1)
			system=Debian
			;;
		2)
			system=Centos
			;;
		*)
			echo '# Error option,exit!'
			exit 1
			;;
	esac
#3.Load config
	configure
#4.Start Install
	mkdir -p "$install_temp"
	cd "$install_temp"
	wget --no-check-certificate https://raw.githubusercontent.com/Char1sma/Shell_Collections/master/Nginx_OneKey/$system/install.sh	
	bash install.sh install
	exit
#	Show Config Info
	$install_path/sbin/nginx -V
	exit
}
function changeversion {
#1.root access check
	rootness
#2.load config
	if [ -f $HOME/nginx_onekey_config ];then
		source $HOME/nginx_onekey_config
		read -p "Please input the nginx version you want to install[1.9.5]:" changever
		if [ ! -n $changever ];then
			changever="1.9.5"
		fi
		rm -f "$HOME/nginx_onekey_config" && cat >> "$HOME/nginx_onekey_config" << EOF
install_temp=$install_temp
nginx_ver=$changever
pcre_ver=$pcre_ver
streamline=$streamline
compile_poz=$compile_poz
pcre_mirror=$pcre_mirror
ossl_ver=$ossl_ver
ossl_mirror=$ossl_mirror
zlib_ver=$zlib_ver
zlib_mirror=$zlib_mirror
mirror=$mirror
n_user=$n_user
n_group=$n_group
install_path=$install_path
conf_path=$conf_path
log_path=$log_path
EOF
	else
		echo "It seems that you don't have install nginx_onekey"
		exit 2;
	fi
#3.upgrade Nginx to any version
	mkdir -p "$install_temp"
	cd "$install_temp"
	wget --no-check-certificate https://raw.githubusercontent.com/Char1sma/Shell_Collections/master/Nginx_OneKey/$system/install.sh
	bash install.sh upgrade
	exit
}
function configure {
	if [ ! -f $HOME/nginx_onekey_config ]; then
		conf_q
	else
		echo "It seems that you cofigured ever?"
		read -p "Do you want to re-configure(Y/n):" key3
		case $key3 in
			N/n)
				echo "Do nothing"
				;;
			*)
				rm "$HOME/nginx_onekey_config" -rf
				conf_q
				;;
		esac	
	fi
}
function conf_q {
	read -p "Do you want to custom installation info?(y/N):" custom
		case $custom in
		Y|y)
			compile_poz="yes"
			read -p "Do you want to Streamlined your VPS ?(y/N):" stream
			case $stream in
			Y|y)
				streamline="yes"
				;;
			*)
				streamline="no"
				;;
			esac
			read -p "Please input the nginx version you want to install[1.9.5]:" nginx_ver
			if [ ! -n $nginx_ver ];then
				nginx_ver="1.9.5"
			fi
			read -p "Please input the pcre version you want to install[8.37]:" pcre_ver
			if [ ! -n $pcre_ver ];then
				pcre_ver="8.37"
			fi
			read -p "Please input the openssl version you want to install[1.0.1q]:" ossl_ver
			if [ ! -n $ossl_ver ];then
				ossl_ver="1.0.1q"
			fi
			read -p "Please input the openssl version you want to install[1.2.7]:" zlib_ver
			if [ ! -n $zlib_ver ];then
				zlib_ver="1.2.7"
			fi
			;;
		*)
			compile_poz="no"
			nginx_ver="1.9.5"
			;;
		esac
		cat >> "$HOME/nginx_onekey_config" << EOF
install_temp=/tmp/nginx_onekey
nginx_ver=$nginx_ver
pcre_ver=$pcre_ver
streamline=$streamline
compile_poz=$compile_poz
pcre_mirror=http://sulinux.stanford.edu/mirrors/exim/pcre
ossl_ver=$ossl_ver
ossl_mirror=http://mirrors.ibiblio.org/openssl/source
zlib_ver=$zlib_ver
zlib_mirror=http://78.108.103.11/MIRROR/ftp/png/src/history/zlib
mirror=https://raw.githubusercontent.com/char1sma/Shell_Collections/master/Nginx_OneKey/Mirrors
n_user=www
n_group=www
install_path=/usr/local/nginx
conf_path=/usr/local/nginx/conf/nginx.conf
log_path=/var/log/nginx
EOF
}
function uninstall {
read -p "Are you sure uninstall ngx_google_deployment? (y/N) " answer
	if [ -z $answer ]; then
		answer="n"
	fi
	if [ "$answer" = "y" ]; then
		source $HOME/nginx_onekey_config
		if [[ -s /etc/rc.local_bak ]]; then
			rm -f /etc/rc.local
			mv /etc/rc.local_bak /etc/rc.local
		fi
		rm -rf $isntall_path
		rm -rf $HOME/nginx_onekey_config
		echo "#Ngx_google_deployment uninstall success!"
	else
		echo "#Uninstall cancelled, Nothing to do"
	fi
}
function rootness {
if [[ $EUID -ne 0 ]]; then
   echo "Error:This script must be run as root!" 1>&2
   exit 1
fi
}
case "$1" in
	install)
		install;;
	change)
		changeversion;;
	uninstall)
		uninstall;;
	configure)
		configure;;
	*)
		echo "unrecognized option:"
		echo "-------------------------------------"
		echo "Usage: $0 [option]"
		echo "$0 install	install Nginx Onekey"
		echo "$0 uninstall	uninstall Nginx Onekey"
		echo "$0 change		change Nginx version"
		echo "$0 configure	custom installation info"
		exit 1
esac
