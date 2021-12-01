#!/bin/bash

# CA Clave y Certificado
openssl genrsa -aes256 -passout pass:Hacking0 -out ca.pass.key 4096
openssl rsa -passin pass:Hacking0 -in ca.pass.key -out ca.key
openssl req -new -x509 -days 730 -key ca.key -out ca.pem -subj "/C=ES/ST=Madrid/O=HackingySeguridad/L=Aldea del Fresno /CN=hacking"

# Clave del servidor y certificado
openssl genrsa -aes256 -passout pass:Hacking0 -out hacking1.pass.key 4096
openssl rsa -passin pass:Hacking0 -in hacking1.pass.key -out hacking1.key
openssl req -new -key hacking1.key -out hacking1.csr -subj "/C=ES/ST=Madrid/O=HackingySeguridad/L=Aldea del Fresno/CN=hacking"
openssl x509 -req -days 730 -sha256 -extensions server_req -in hacking1.csr -CA ca.pem -CAkey ca.key -CAcreateserial -CAserial 1 -out hacking1.pem

# client_cdg Clave privada y certificados
openssl genrsa -aes256 -passout pass:Hacking0 -out client_cdg.pass.key 4096
openssl rsa -passin pass:Hacking0 -in client_cdg.pass.key -out client_cdg.key
rm client_cdg.pass.key
openssl req -config ca.conf -new -key client_cdg.key -out client_cdg.csr -subj "/C=ES/ST=Madrid/O=HackingySeguridad/L=Aldea del Fresno/CN=hacking"
openssl x509 -req -days 730 -sha256 -extfile ca.conf -extensions v3_req -in client_cdg.csr -CA ca.pem -CAkey ca.key -CAcreateserial -CAserial 1 -out client_cdg.pem
openssl pkcs8 -topk8 -inform PEM -outform PEM -in client_cdg.key -out client_cdg.pkcs8.withpass.key -passout pass:Hacking0
keytool -keystore client_cdg.truststore.jks -alias CAROOT -import -file ca.pem -storepass Hacking0 -noprompt
openssl pkcs12 -export -in client_cdg.pem  -inkey client_cdg.key -out client_cdg.pfx -passout pass:Hacking0
keytool -importkeystore -deststorepass Hacking0 -destkeystore client_cdg.keystore.jks -srckeystore client_cdg.pfx -srcstoretype PKCS12 -noprompt -srcstorepass Hacking0

# Genera Keystore
openssl pkcs12 -export -in hacking1.pem  -inkey hacking1.key -out hacking1.pfx -passout pass:Hacking0
keytool -importkeystore -deststorepass Hacking0 -destkeystore hacking1.keystore.jks -srckeystore hacking1.pfx -srcstoretype PKCS12 -noprompt -srcstorepass Hacking0

# Genera Truststore
keytool -keystore server.truststore.jks -alias CAROOT -import -file ca.pem -storepass Hacking0 -noprompt
