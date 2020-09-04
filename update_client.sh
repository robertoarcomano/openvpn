#!/bin/bash

if [ -z "$1" ]; then
  echo "Syntax: <NAME>"
  exit
fi

DIR=`dirname $0`
CLIENT_NAME=$1
DIR_CLIENT=$DIR/openvpn/$CLIENT_NAME
CONF=$DIR/client.conf
CA=$(cat  $DIR_CLIENT/ca.crt)
CERT=$(cat $DIR_CLIENT/$CLIENT_NAME.crt)
KEY=$(cat $DIR_CLIENT/$CLIENT_NAME.key)
TLS_AUTH=$(cat $DIR_CLIENT/ta.key)
sudo sed -ri "s/<ca><\/ca>/<ca>$CA<\/ca>/" $CONF
sudo sed -ri "s/<cert><\/cert>/<cert>$CERT<\/cert>/" $CONF
sudo sed -ri "s/<key><\/key>/<key>$KEY<\/key>/" $CONF
sudo sed -ri "s/<tls-auth><\/tls-auth>/<tls-auth>$TLS_AUTH<\/tls-auth>/" $CONF

echo "PWD: $PWD"
echo "DIR_CLIENT: $DIR_CLIENT"
echo "CLIENT_NAME: $CLIENT_NAME"
echo "ls -al " $DIR_CLIENT"/"$CLIENT_NAME
find $DIR_CLIENT