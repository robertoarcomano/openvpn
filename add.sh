#!/bin/bash

cd openvpn
CLIENTS="new"
for CLIENT_NAME in $CLIENTS; do

  # 15. Client key and certificate request
  echo 15. Client key and certificate request
  cd .. && rm -rf client && make-cadir client && cd client || exit
  cat >> vars << EOF
set_var EASYRSA_REQ_COUNTRY     "IT"
set_var EASYRSA_REQ_PROVINCE    "Piemonte"
set_var EASYRSA_REQ_CITY        "Torino"
set_var EASYRSA_REQ_ORG "Roberto Arcomano"
set_var EASYRSA_REQ_EMAIL       "bertolinux@gmail.com"
set_var EASYRSA_REQ_OU          "bertolinux"
EOF
  ./easyrsa init-pki

  # 16. Create client certificate
  echo 16. Create client certificate
  ../gen-req-client.exp $CLIENT_NAME

  # 17. Import client req
  echo 17. Import client req
  cd ../certificate_authority && ./easyrsa import-req ../client/pki/reqs/client.req client

  # 18. Sign client req
  echo 18. Sign client req
  ../sign-req-client.exp $CLIENT_NAME

  # 19. Copy client.crt and client.key
  mkdir -p ../openvpn/$CLIENT_NAME
  cp ../client.conf ../openvpn/$CLIENT_NAME
  cp ../openvpn/{ca.crt,dh.pem,ta.key} ../openvpn/$CLIENT_NAME
  mv pki/issued/client.crt ../openvpn/$CLIENT_NAME/$CLIENT_NAME.crt
  mv ../client/pki/private/client.key ../openvpn/$CLIENT_NAME/$CLIENT_NAME.key
  rm -f ../client/pki/reqs/client.req
  rm -f pki/private/client.key
  rm -f pki/reqs/client.req
  ../update_client.sh $CLIENT_NAME
done
