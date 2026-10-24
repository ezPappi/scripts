#!/bin/sh

OLDIP=`cat /etc/postfix/relays`                 ## IP after last check                  ##
NEWIP=`host ezunix.ath.cx|awk '{print $4}'`     ## Check latest IP                      ##
RELAY_FILE="/etc/postfix/relays"

update_ip()
{
        echo $NEWIP > $RELAY_FILE
}

if [ "$OLDIP" = "$NEWIP" ]; then
        exit 0;
fi

if [ "$OLDIP" != "$NEWIP" ]; then
        # Check if we got an IP address back. Don't run updates if not.
        regex="\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b"
        CHECK=$(echo $NEWIP | egrep $regex)
        if [ "$?" -eq 0 ]; then
                update_ip
                echo "UPDATED to $NEWIP"
        fi
fi

exit 0;
