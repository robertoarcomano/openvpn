#!/bin/bash

if [ -z "$1" ]; then
  echo "Syntax: <NAME>"
  exit
fi

DIR=`dirname $0`
DIR_CLIENT=$DIR/openvpn/$CLIENT_NAME
CLIENT_NAME=$1
CONF=$DIR/client.conf
CA=$(cat $DIR/ca.crt)
CERT=$(cat $DIR_CLIENT/$CLIENT_NAME.crt)
KEY=$(cat $DIR_CLIENT/$CLIENT_NAME.key)
TLS_AUTH=$(cat $DIR_CLIENT/ta.key)
sudo sed -ri "s/<ca><\/ca>/<ca>$CA<\/ca>/" $CONF
sudo sed -ri "s/<cert><\/cert>/<cert>$CERT<\/cert>/" $CONF
sudo sed -ri "s/<key><\/key>/<key>$KEY<\/key>/" $CONF
sudo sed -ri "s/<tls-auth><\/tls-auth>/<tls-auth>$TLS_AUTH<\/tls-auth>/" $CONF
