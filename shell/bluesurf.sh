#!/bin/sh

###
# This script will connect your looniks to a bluetooth device
# and gain IP address from the DHCP server on this device.
# Created by: Marcin M. Jessa - yazzy@yazzy.org
# Last change:	09.th July 2007
###

# ToDo:
# Find the devices automagically, list them, let the user chose one and store it as a variable, then work with this variable.
# Code it in python or ruby (with ncurses) };)

# Include colors.disp with definitions of the colours we use:
. colors.disp

SUDO=${SUDO:-`which sudo`}      	# Where to find sudo
PAND=${PAND:- `which pand`}		# Where to find pand
DHCLIENT=${DHCLIENT:- `which dhclient`}	# Where to find dhcp client
HCITOOL=${HCITOOL:- `which hcitool`}	# Where to find the bluetooth tool

#Some colour functions
showerr()
{
        echo "${RED}${UNDERLINE}${BLINKWHITE}$@${NORMAL}"
}
warning()
{
        echo "${YELLOW}===> $@${NORMAL}"
}

showchoices() {
		echo ""
                showerr "Please type in one of the arguments:"${NORMAL}${BLUE}"(c)onnect, (n)etwork or (d)isconnect."
                echo ""
}

## To scan for avaliable devices - hcitool scan

case $1 in
	"") ### Show the message when no arguments are given.	
		showchoices ;;

	[Cc]|[Cc][Oo][Nn][Nn][Ee][Cc][Tt])
			echo Connecting to the bluetooth network through bnep0	...
			${SUDO} ${PAND} --connect 00:17:E4:98:46:EB -n
                	echo "" ;;

	[Nn]|[Nn][Ee][Tt][Ww][Oo][Rr][Kk])
			echo Running DHCP on bnep0 ...
			${SUDO} ${DHCLIENT} bnep0
        	        echo "" ;;

	[Dd]|[Dd][Ii][Ss][Cc][Oo][Nn][Nn][Ee][Cc][Tt])
			echo Disconnecting ...
			${SUDO} ${HCITOOL} dc 00:17:E4:98:46:EB
        	        echo "" ;;

	*) ### Show the message for every other option.
			showchoices ;;
esac
