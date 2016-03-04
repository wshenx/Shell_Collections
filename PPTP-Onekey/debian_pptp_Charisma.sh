#!/bin/bash
clear
function check_sanity {
	# Do some sanity checking.
	if [ $(/usr/bin/id -u) != "0" ]
	then
		die 'Must be run by root user'
	fi

	if [ ! -f /etc/debian_version ]
	then
		die "Distribution is not supported"
	fi
}

function die {
	echo "ERROR: $1" > /dev/null 1>&2
	exit 1
}
function installVPN(){
	apt-get update
	#remove ppp pptpd
	rm -rf /etc/pptpd.conf
	rm -rf /etc/ppp
	apt-get -y --force-yes remove ppp pptpd 
	
	apt-get -y --force-yes install ppp pptpd iptables curl
	
	echo ms-dns 8.8.8.8 >> /etc/ppp/pptpd-options
	echo ms-dns 208.67.220.220 >> /etc/ppp/pptpd-options
	echo localip 192.168.99.1 >> /etc/pptpd.conf
	echo remoteip 192.168.99.9-99 >> /etc/pptpd.conf
    
	IP=`curl -s checkip.dyndns.com | cut -d' ' -f 6  | cut -d'<' -f 1`
	if [ -z $IP ]; then
    IP=`curl -s ifconfig.me/ip`
	fi
	
	iptables -t nat -A POSTROUTING -s 192.168.99.0/24 -j SNAT --to-source $IP
	sed -i 's/exit\ 0/#exit\ 0/' /etc/rc.local
    
	echo iptables -t nat -A POSTROUTING -s 192.168.99.0/24 -j SNAT --to-source $IP >> /etc/rc.local
	echo exit 0 >> /etc/rc.local
	echo net.ipv4.ip_forward = 1 >> /etc/sysctl.conf
	sysctl -p
	# --- the sentence below was remarked By yanwen ,  what are you doing ??-----
	# echo ystest \* intel \* >> /etc/ppp/chap-secrets
	/etc/init.d/pptpd restart
}

function uninstallVPN(){
    echo "begin to uninstall VPN";
    apt-get -y --force-yes remove ppp pptpd 
	sed -i '/192.168.99.0/d' /etc/rc.local 
	sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf
	sysctl -p
}
function repaireVPN(){
	echo "begin to repaire VPN";
	mknod /dev/ppp c 108 0
	/etc/init.d/pptpd restart
}

function adduser(){
	echo "input user name:"
	read username
	echo "input password:"
	read userpassword
	echo "${username} pptpd ${userpassword} *" >> /etc/ppp/chap-secrets
	/etc/init.d/pptpd restart
}

######################### Initialization ################################################
# Make sure only root can run our script
check_sanity
action=$1
case "$action" in
uninstall)
    uninstallVPN
    ;;
repaire)
    repaireVPN
    ;;
adduser)
    adduser
    ;;	
*)
		installVPN
		;;
esac
