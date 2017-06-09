#!/bin/sh

#NODES="deva devb devc devd"
NODES="zeus"
SSHKEY="/secret/plase/.ssh/id_rsa_nodes_key"
USER="xyz"
DATE=`date +"%Y-%m-%d %H:%M"`
TMPFILE=`mktemp /tmp/node.tmp.XXXXXXXX`		# Temp file

connect_nodes() {
  for SERVER in $NODES; do
    echo '
#    spawn 'ssh' '${SERVER}' -l '${USER}' -i '${SSHKEY}'
    spawn 'ssh' '${SERVER}' -l '${USER}'
    #
    expect -re "] > "
#    send "'get x509 cert'\r"
    send "'get x509 cert'\r"
#    sleep 2
    #
    expect -re "] > " exit
    ' > ${TMPFILE}

    expect ${TMPFILE}

    rm -f ${TMPFILE}
    exit 0
done
}

connect_nodes
