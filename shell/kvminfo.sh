#!/bin/sh

###################################################
### This script will do various things with KVM ###
### Written by yazzy@yazzy.org			###
### Last change 30.01.2013			###
###################################################

############################################################
# show usage message and exit
############################################################

DOMAINS=`virsh list|awk '{print $2}'|grep -v Name`
VERSION="Version 0.1"

showmem() {
TOTAL_MEMORY=`cat /proc/meminfo |grep MemTotal|awk '{print $2}'`

for DOMAIN in $DOMAINS; do
	echo "Virtual server: $DOMAIN"
	USED_MEMORY_PER_DOMAIN=`virsh dommemstat $DOMAIN|grep -v rss|awk '{print $2}'`
	TOTAL_USED_MEMORY=`expr $USED_MEMORY_PER_DOMAIN + $USED_MEMORY_PER_DOMAIN`;
	virsh dommemstat $DOMAIN;
done

echo "\nTotal memory available on the server: $TOTAL_MEMORY Kb"
echo "Total memory assigned the virtual servers: $TOTAL_USED_MEMORY Kb"
}


showdevices(){
echo "Devices used by virtual machines:\n"
	POOLS=`vgdisplay |grep "VG Name"|awk '{print $3}'|uniq`
	for POOL in $POOLS; do
		virsh vol-list --details $POOL|grep -v error
	done
}

usage() {
cat <<EOF
usage:  $0 [options]

Options:
    -h,--help           	Show this help.
    -s,--showmem showmem	Show memory usage
    -d,--dev showdev		Show devices used by the virtual hosts
    -v,--ver 			Show version of this script
EOF
    exit $1
}


############################################################
# Parse the command line, bro!
############################################################
while test $# -gt 0; do
	case "$1" in
		-s|--showmem) showmem ;;
		?|-h|--help) usage ;;
		-d|--dev) showdevices ;;
		-v|--version) echo $VERSION;;
		--) shift; break;;  # no more options
		-*) usage ;;
		*) break;; # not option, its some argument
	esac
	shift
done

#if [ -z "$1" ]; then
#	    usage
#   exit 1
#fi
