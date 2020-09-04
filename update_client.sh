#!/bin/bash

if [ -z "$1" ]; then
  echo "Syntax: <NAME>"
  exit
fi

DIR=`dirname $0`
CLIENT_NAME=$1
CONF=$DIR/client.conf
CONF=client.conf
#echo "DIR: $DIR"
#exit
CA=$(cat ca.crt)
CERT=$(cat $CLIENT_NAME.crt)
KEY=$(cat $CLIENT_NAME.key)
TLS_AUTH=$(cat ta.key)
sudo sed -ri "s/<ca><\/ca>/<ca>$CA<\/ca>/" $CONF
sudo sed -ri "s/<cert><\/cert>/<cert>$CERT<\/cert>/" $CONF
sudo sed -ri "s/<key><\/key>/<key>$KEY<\/key>/" $CONF
sudo sed -ri "s/<tls-auth><\/tls-auth>/<tls-auth>$TLS_AUTH<\/tls-auth>/" $CONF
