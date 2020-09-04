#!/bin/bash

CA=$(cat ca.crt)
CERT=$(cat client.crt)
KEY=$(cat client.key)
TLS_AUTH=$(cat ta.key)
sudo sed -ri "s/<ca><\/ca>/<ca>$CA<\/ca>/" client.conf
sudo sed -ri "s/<cert><\/cert>/<cert>$CERT<\/cert>/" client.conf
sudo sed -ri "s/<key><\/key>/<key>$KEY<\/key>/" client.conf
sudo sed -ri "s/<tls-auth><\/tls-auth>/<tls-auth>$TLS_AUTH<\/tls-auth>/" client.conf
