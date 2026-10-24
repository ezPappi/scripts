#!/bin/sh
# This script is written by yazzy@yazzy.org meant to be used on FreeBSD and Linux.
# It's goal is to create a convinient way to burn misc file types with command line.
# It uses libdialog for the funky menu.
# It will also install cdrecord and cdrdao from the ports collection or as a binary package if not present.
# Thanks masta for his ideas and assisting me with this one and other scripts.

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
 
DIALOG=${DIALOG:-`which dialog`}			# Where we have dialog executable
CDRECORD=${CDRECORD:-`which cdrecord`}			# Where to find cdrecord
CDRDAO=${CDRDAO:-`which cdrdao`}			# Location of cdrdao
GROWISOFS=${GROWISOFS:-`which growisofs`}
UNAME=${UNAME:-`which uname`}
CHECKLIST=`mktemp /tmp/checklist.tmp.XXXXXXXX`		# Temp file
BURNPATH="/fridge/burn"					# Where I keep my files I burn
DEV="15,0,0"						# SCSI device
SPEED_RW="24"						# Desired CDRW speed
SPEED_BLANK="4"						# How fast to blank your CD

### Functions: ###

# Burn ISO:
burn_iso() {
	echo "'${CHOICE}' chosen. Burning ISO..."
	for x in *.iso; 
	do ${CDRECORD} -v dev=${DEV} fs=48m speed=${SPEED_RW} -v -eject -pad -data "$x"  >|/tmp/ERRORS$$ 2>&1
	done  
# zero status indicates burning was successful
        if [ "$?" = "0" ]
            then
            $DIALOG --title "Burning of ISO file" --msgbox "Burning of your ISO file completed successfully." 10 50
        else
        # Burning of ISO failed, display error log
            $DIALOG --title "Burning" --msgbox "Burning failed  -- Press <Enter> to see error log." 10 50
                $DIALOG --title "Error Log" --textbox /tmp/ERRORS$$ 22 83

fi
        rm -f /tmp/ERRORS$$
        clear

}

# Burn BIN:
burn_bin() {
	echo " '${CHOICE}' chosen. Burning BIN..."
	for x in *.cue; do
	${CDRDAO} write --device ${DEV} --eject -v 1 "$x"  >|/tmp/ERRORS$$ 2>&1
	done 
# zero status indicates burning was successful
        if [ "$?" = "0" ]
            then
            $DIALOG --title "Burning of BIN file" --msgbox "Burning of your BIN file completed successfully." 10 50
        else
        # Burning of BIN failed, display error log
            $DIALOG --title "Burning" --msgbox "Burning failed  -- Press <Enter> to see error log." 10 50
                $DIALOG --title "Error Log" --textbox /tmp/ERRORS$$ 22 82

fi
        rm -f /tmp/ERRORS$$
        clear
}

# Burn DVD:
burn_dvd() {
	if	[ ! -d ${BURNPATH} ]; then 
		$DIALOG --title "Error !!!" --msgbox "Your directory ${BURNPATH} does not exists! Please create it first!" 10 50 
		exit 255
	else 
		echo " '${CHOICE}' chosen. Burning DVD..."
		${GROWISOFS} -Z ${DEV} -R -J ${BURNPATH}  >|/tmp/ERRORS$$ 2>&1
# zero status indicates burning was successful
        if [ "$?" = "0" ]
            then
            $DIALOG --title "Burning of DVD" --msgbox "Burning of your DVD completed successfully." 10 50
        else
        # Burning of BIN failed, display error log
            $DIALOG --title "Burning" --msgbox "Burning failed  -- Press <Enter> to see error log." 10 50
                $DIALOG --title "Error Log" --textbox /tmp/ERRORS$$ 22 82

fi
        rm -f /tmp/ERRORS$$
        clear

       fi
}
# Burn WAVs:
burn_wavs() {

	echo "'${CHOICE}' chosen. Burning music CD..."
	${CDRECORD} -v speed=${SPEED_RW} dev=${DEV} -eject -audio -pad *.wav  >|/tmp/ERRORS$$ 2>&1

# zero status indicates burning was successful
        if [ "$?" = "0" ]
            then
            $DIALOG --title "Burning of music CD" --msgbox "Burning of your music CD completed successfully." 10 50
        else
        # Burning of music CD failed, display error log
            $DIALOG --title "Burning" --msgbox "Burning failed  -- Press <Enter> to see error log." 10 50
                $DIALOG --title "Error Log" --textbox /tmp/ERRORS$$ 22 83

fi
        rm -f /tmp/ERRORS$$
        clear
}

# Blank CDRW:
blank_cdrw() {
#	$DIALOG --title "INFO" --infobox "${CHOICE} chosen. Please wait. Blanking CDRW" 10 30 ; sleep 4
	echo "'${CHOICE}' chosen. Blanking CDRW"

#Note: blank=fast may not work on every CDRW. In cases like that use blank=all instead
	${CDRECORD} -v speed=${SPEED_BLANK} dev=${DEV} blank=fast >|/tmp/ERRORS$$ 2>&1 && 
#$DIALOG --title "Blanking status" --textbox tail -F /tmp/ERRORS$$ 10 30 ;
# zero status indicates burning was successful
	if [ "$?" = "0" ]
	    then
	    $DIALOG --title "Blanking" --msgbox "Blanking of your CDRW completed successfully." 10 50
	else
	# Blanking failed, display error log
	    $DIALOG --title "Blanking" --msgbox "Blanking failed  -- Press <Enter> to see error log." 10 50
		$DIALOG --title "Error Log" --textbox /tmp/ERRORS$$ 22 72

fi
	rm -f /tmp/ERRORS$$
	clear
}

### Main function: ###

run_script() {

MAINMENU=`cat <<-EOF
	This is simple frontend to burn CDs and DVDs.
	You can use it to burn ISO and BIN images or WAV 
	files as music CDs in your current directory. 
	You can also burn ${BURNPATH} directory to your DVD.
	Press SPACE to chose an option. 
  
	Which of the following do you want to do?
EOF
`
  
$DIALOG --title "CD/DVD Burning." --clear \
	--radiolist "${MAINMENU}" -1 -1 5 \
	"ISO"   "Burn .iso image."  off \
	"BIN"   "Burn .bin file."   off \
	"DVD"   "Burn your ${BURNPATH} directory to DVD."   off \
	"WAVs"  "Burn *.wav files." off \
	"Blank" "Blank your CDRW."  off 2> ${CHECKLIST} || exit $?

CHOICE=`cat ${CHECKLIST}`
rm -f ${CHECKLIST}

echo "CHOICE = ${CHOICE}"
  

case ${CHOICE} in

ISO)
	burn_iso
	;;
BIN)
	burn_bin
	;;

DVD)
	burn_dvd
	;;


WAVs)
	burn_wavs
	;;

Blank)
	blank_cdrw
;;
  
esac

#
# Exit with no errors.
#
        
exit 0

}


### Check if our O.S is supported ### 

case "`${UNAME} -s`" in

FreeBSD|NetBSD|OpenBSD)

#type cdrecord 2>&1 | /usr/bin/grep " is " >/dev/null || {
#	if	[ -f /usr/ports/sysutils/cdrtools/Makefile ]; then
#			( cd /usr/ports/sysutils/cdrtools && /usr/bin/make install && /usr/bin/make clean )
#	else	pkg_add -r cdrtools || {
#				echo "Could not get it via pkg_add - please go install this"
#				echo "from the ports collection and run this script again."
#				exit 255
#			}
#	fi
#}

	run_script

;;

Linux)
	run_script
;;

*)

echo "This O.S is not supported by the script."
;;

esac

#
# Exit with no errors.
#

exit 0
