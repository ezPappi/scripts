#!/bin/sh

#
# Create a script that will ssh to each node and check for certificate expiration.
# The script should also send e-mail five days before expiration, with node name and certificate details,
# and another e-mail when cert expires in less than 2 days. Please notice, that it should be easy to add another node to the list.
# Also, another warning mail should be sent if the node is unavailable. A summary log after the work is done, would be a nice add-on.


#NODES="deva devb devc devd"
#REMOTE_COMMAND="get x509 cert"
#SSHKEY="/secret/place/.ssh/id_rsa_nodes_key"
NODES="zeus"
SSHKEY="/Users/mmj/.ssh/id_rsa_home"
USER="mmj"
NOW_DATE=`date +"%Y-%m-%d"`
DATE_2_DAYS_AGO=`date +%Y-%m-%d --date='2 day ago'`
DATE_5_DAYS_AGO=`date +%Y-%m-%d --date='5 day ago'`
SUBJECT="Certificate expiration warning"
EMAIL="yazzy@yazzy.org"

NOW_TIME=`date +"%H:%M"`

TMPFILE=`mktemp /tmp/node.tmp.XXXXXXXX`		# Temp file
REMOTE_COMMAND="cat /home/mmj/certs.txt"

check_certs() {
  for SERVER in $NODES; do
    ssh ${USER}@${SERVER} -i ${SSHKEY} -t ${REMOTE_COMMAND} 2>&1 | tee > ${TMPFILE}

      while read LINE; do
       CERT_DATE=`echo ${LINE} | cut -d" " -f3 | sed 's/exp<DATE://' | sed 's/>//'`
       CERT_NAME=`echo ${LINE} | cut -d" " -f1 | sed 's/<//' | sed 's/>//'`
        if[ ${CERT_DATE} -eq ${DATE_2_DAYS_AGO} ]; then
          echo "Node: ${SERVER} CERT: ${LINE} will expire in 2 days"
         # echo "Node: ${SERVER} CERT: ${LINE} will expire in 2 days" | /bin/mail -s $SUBJECT $EMAIL
       elif[ ${CERT_DATE} -eq ${DATE_5_DAYS_AGO} ]; then
          echo "Node: ${SERVER} CERT: ${LINE} will expire in 5 days"
         # echo "Node: ${SERVER} CERT: ${LINE} will expire in 5 days" | /bin/mail -s $SUBJECT $EMAIL
       fi
     done < ${TMPFILE}

    rm -f ${TMPFILE}
    exit 0
done
}

check_certs
