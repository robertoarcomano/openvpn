#!/bin/bash

if [ -z "$1" ]; then
  echo "Syntax: <NAME>"
  exit
fi

DIR=`dirname $0`
CLIENT_NAME=$1
DIR_CLIENT=$DIR/openvpn/$CLIENT_NAME
CONF=$DIR_CLIENT/client.conf
CA=$(cat  $DIR_CLIENT/ca.crt)
CERT=$(cat $DIR_CLIENT/$CLIENT_NAME.crt)
KEY=$(cat $DIR_CLIENT/$CLIENT_NAME.key)
TLS_AUTH=$(cat $DIR_CLIENT/ta.key)

cat >> $CONF << EOF
<ca>
$CA
</ca>
EOF

cat >> $CONF << EOF
<cert>
$CERT
</cert>
EOF

cat >> $CONF << EOF
<key>
$KEY
</key>
EOF

cat >> $CONF << EOF
<tls-auth>
$TLS_AUTH
</tls-auth>
EOF
