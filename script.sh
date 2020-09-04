#!/bin/bash

# 0. Remove older directories
echo 0. Remove older directories
rm -rf certificate_authority server openvpn

# 1. Install easyrsa, expect
echo 1. Install easyrsa, expect
sudo apt-get -y install easy-rsa expect

# 2. Create and enter CA directory
echo 2. Create and enter CA directory
make-cadir certificate_authority && cd certificate_authority || exit

# 3. Edit file vars
echo 3. Edit file vars
cat >> vars << EOF
set_var EASYRSA_REQ_COUNTRY     "IT"
set_var EASYRSA_REQ_PROVINCE    "Piemonte"
set_var EASYRSA_REQ_CITY        "Torino"
set_var EASYRSA_REQ_ORG "Roberto Arcomano"
set_var EASYRSA_REQ_EMAIL       "bertolinux@gmail.com"
set_var EASYRSA_REQ_OU          "bertolinux"
EOF

# 4. Generate PKI
echo 4. Generate PKI
./easyrsa init-pki

# 5. Generate CA-key and Certificate
echo 5. Generate CA-key and Certificate
mv ../build-ca.exp . && ./build-ca.exp

# 6. Step 2,3,4 for server directory
echo 6. Step 2,3,4 for server directory
cd .. && make-cadir server && cd server || exit
cat >> vars << EOF
set_var EASYRSA_REQ_COUNTRY     "IT"
set_var EASYRSA_REQ_PROVINCE    "Piemonte"
set_var EASYRSA_REQ_CITY        "Torino"
set_var EASYRSA_REQ_ORG "Roberto Arcomano"
set_var EASYRSA_REQ_EMAIL       "bertolinux@gmail.com"
set_var EASYRSA_REQ_OU          "bertolinux"
EOF
./easyrsa init-pki

# 7. Create server certificate
echo 7. Create server certificate
mv ../gen-req-server.exp . && ./gen-req-server.exp

# 8. Prepare output directory
echo 8. Prepare output directory
cd .. && mkdir openvpn && cd openvpn || exit

# 9. Copy server key
echo 9. Copy server key
mv ../server/pki/private/server.key .

# 10. Import server req
echo 10. Import server req
cd ../certificate_authority && ./easyrsa import-req ../server/pki/reqs/server.req server

# 11. Sign req
echo 11. Sign req
mv ../sign-req-server.exp . && ./sign-req-server.exp

# 12. Copy CA and server certificates
echo 12. Copy CA and server certificates
cp pki/{ca.crt,issued/server.crt} ../openvpn

# 13. Deffie-Hellman, create and copy
echo 13. Deffie-Hellman, create and copy
# ./easyrsa gen-dh
# mv pki/dh.pem ../openvpn
# Debugging purpose
cp ../../dh.pem ../openvpn

# 14. Generate ta.key
echo 14. Generate ta.key
cd ../openvpn && openvpn --genkey --secret ta.key || exit

#mv ../gen-req-client.exp .
#mv ../sign-req-client.exp .

CLIENTS="oracle1 oracle2 oracle3 oracle4 toshiba google clevo"
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
  cp ../openvpn/{ca.crt,dh.pem,ta.key} ../openvpn/$CLIENT_NAME
  mv pki/issued/client.crt ../openvpn/$CLIENT_NAME/$CLIENT_NAME.crt
  mv ../client/pki/private/client.key ../openvpn/$CLIENT_NAME/$CLIENT_NAME.key
  rm -f ../client/pki/reqs/client.req
  rm -f pki/private/client.key
  rm -f pki/reqs/client.req
done

