#!/bin/sh

#########################
#  Connect to F5 VPN	#
#########################

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Exiting." 1>&2
   exit 1
fi

HOSTNAME="vpn.server.tld"
VPNCLIENT="/usr/local/bin/f5fpc"
USERNAME="abcdef"	# VPN user
ETH_IF="enp0s3"		# Ethernet interface. Nameing may depand on virtualization used.
TUN_IF="tun0"		# Tunnel interface. Should be the same.

add_nat() {
	echo "Setting up NAT rules."
	sleep 5
	echo 1 > /proc/sys/net/ipv4/ip_forward
	/sbin/iptables -t nat -A POSTROUTING -o $TUN_IF -j MASQUERADE
	/sbin/iptables -A FORWARD -i $ETH_IF -o $TUN_IF -j ACCEPT
	/sbin/iptables -A FORWARD -i $TUN_IF -o $ETH_IF -m state --state RELATED,ESTABLISHED -j ACCEPT
	echo "Done setting up NAT rules."
}
remove_nat() {
	echo "Removing NAT rules."
	echo 0 > /proc/sys/net/ipv4/ip_forward
	/sbin/iptables -F
	/sbin/iptables -t nat -F
	/sbin/iptables -t mangle -F
	echo "Done removing NAT rules."
}

case ${1} in
	[Cc]|[Cc][Oo][Nn][Nn][Ee][Cc][Tt])
		if [ ! -f $VPNCLIENT ] ; then
			echo
			echo "Cannot find the VPN Client in $VPNCLIENT. Maybe it is not installed?"
			echo "----------------------------"
		else
			if [ -x $VPNCLIENT ] ; then
				$VPNCLIENT --start -t $HOSTNAME -u $USERNAME --nocheck
				remove_nat
				add_nat
			else
				echo
				echo "VPN Client is not an executable."
				echo "--------------------------------"
			fi
		fi
	;;
	[Dd]|[Dd][Ii][Ss][Cc][Oo][Nn][Nn][Ee][Cc][Tt])
		if [ ! -f $VPNCLIENT ] ; then
			echo
			echo "Cannot find the VPN Client in $VPNCLIENT. Maybe it is not installed?"
			echo "----------------------------"
		else
			if [ -x $VPNCLIENT ] ; then
				$VPNCLIENT --stop
				remove_nat
			else
				echo
				echo "VPN Client is not an executable."
				echo "--------------------------------"
			fi
		fi
	;;

	[Ii]|[Ii][Nn][Ff][Oo])
		$VPNCLIENT --info
	;;

	*)
		echo
		echo "Please use either '(C)onnect', '(D)isconnect' or (I)nfo."
esac
