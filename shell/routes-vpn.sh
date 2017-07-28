#!/bin/sh

###########################################################
### This script is for Mac OSX. Testet on OSX 10.12.6   ###
### Route VPN traffic through a Linux VirtualBox VM	###
### Written by yazzy@yazzy.org  	        	###
### Last change 28.07.17			  	###
###########################################################


# Make sure only root can run this script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Exiting." 1>&2
   exit 1
fi

### Define variables ###
VM_NAME="Debian"
VPN_DNS_SEARCH="domain.one.tld domain-two.tld"
VPN_DNS1="11.22.33.44"		# DNS 1 on the VPN side
VPN_DNS2="22.33.44.55"		# DNS 2 on the VPN side
USER="user_name"		# Local user you run VirtualBox as
ADAPTER=`su - $USER -c "/usr/local/bin/VBoxManage showvminfo $VM_NAME --machinereadable" |grep bridgeadapter1| awk '{print $2}' `  # Bridge device of the VM
### END of variables ###


# Find local IP address of our VM
find_GW_IP() {
m=`su - $USER -c "VBoxManage showvminfo $VM_NAME --machinereadable" |grep macaddress1| cut -d '"' -f2 |tr '[A-Z]' '[a-z]' `
VM_MAC=$(echo `expr ${m:0:2}`:`expr ${m:2:2}`:`expr ${m:4:2}`:`expr ${m:6:2}`:`expr ${m:8:2}`:`expr ${m:10:2}`)

# Get VM's IP from its MAC address
VM_IP=`/usr/sbin/arp -a | grep $VM_MAC | awk '{print $2}'|cut -d '(' -f2 |cut -d ')' -f1`

if [ ! -z "$VM_IP" ]; then
	GWIP = $VM_IP
else
	echo "Cannot find IP address of the gateway! Exiting."
	exit 1
fi
}

update_dns(){ 
if [ "$ROUTE_CMD" = "add" ]; then
	    echo "Updating DNS for $ADAPTER"
    	# Get current DNS value
    	DNSSVR=(`networksetup -getdnsservers $ADAPTER`)
    	DNS_SEARCH=(`networksetup -getsearchdomains $ADAPTER`)
	    # Set DNS server to the VPN DNS server plus local DNS server
    	networksetup -setdnsservers $ADAPTER $VPN_DNS1 $VPN_DNS2 $DNSSVR
    	networksetup -setsearchdomains $ADAPTER $DNS_SEARCH $VPN_DNS_SEARCH

elif [ "$ROUTE_CMD" = "delete" ]; then
    	# Revert back to DHCP assigned DNS Servers
        networksetup -setdnsservers $ADAPTER empty |grep -v Error |grep -v "not a recognized" |grep -v "No matching"
else
    	networksetup -getsearchdomains $ADAPTER |grep -v Error |grep -v "not a recognized" |grep -v "No matching"
    	networksetup -getdnsservers $ADAPTER |grep -v Error |grep -v "not a recognized" |grep -v "No matching"
    	networksetup -getinfo $ADAPTER |grep -v Error |grep -v "not a recognized" |grep -v "No matching"
    	
fi

}

case ${1} in
        [Cc]|[Cc][Oo][Nn][Nn][Ee][Cc][Tt])
		# Add new VPN routes 
		ROUTE_CMD="add"
		find_GW_IP
		# Update DNS
		update_dns
		# Finally flush DNS cache
    	killall -HUP mDNSResponder;sudo killall mDNSResponderHelper;sudo dscacheutil -flushcache
	;;

	[Dd]|[Dd][Ii][Ss][Cc][Oo][Nn][Nn][Ee][Cc][Tt])
		# Delete VPN routing
		ROUTE_CMD="delete"
		find_GW_IP
		# Update DNS
		update_dns
		# Finally flush DNS cache
    	killall -HUP mDNSResponder;sudo killall mDNSResponderHelper;sudo dscacheutil -flushcache
	;;
        [Ii]|[Ii][Nn][Ff][Oo])
        # Get networking info
        update_dns
		exit 0
        ;;

        *)
                echo
                echo "Please use either (C)onnect, (D)isconnect or (I)nfo."
		exit 1
esac

# Add custom VPN routes:
route -n $ROUTE_CMD -net 10.20.0.0/16 $GWIP
route -n $ROUTE_CMD -net 10.30.0.0/24 $GWIP
route -n $ROUTE_CMD -net 10.40.0.0/24 $GWIP
route -n $ROUTE_CMD -net 10.50.0.0/24 $GWIP
route -n $ROUTE_CMD -net 10.100.0.0/16 $GWIP
