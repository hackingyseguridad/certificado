#!/bin/bash

# CA Key and Certificate
openssl genrsa -aes256 -passout pass:Temporal0 -out ca.pass.key 4096
openssl rsa -passin pass:Temporal0 -in ca.pass.key -out ca.key
rm ca.pass.key
openssl req -config ca.conf -new -x509 -days 730 -key ca.key -out ca.pem -subj "/C=ES/ST=Madrid/O=Cisco/L=Alcobendas/CN=kafka"

# Server Key and Certificate
openssl genrsa -aes256 -passout pass:Temporal0 -out kafka1.pass.key 4096
openssl rsa -passin pass:Temporal0 -in kafka1.pass.key -out kafka1.key
rm kafka1.pass.key
openssl req -config ca.conf -new -key kafka1.key -out kafka1.csr -subj "/C=ES/ST=Madrid/O=Cisco/L=Alcobendas/CN=kafka"
openssl x509 -req -days 730 -sha256 -extfile ca.conf -extensions server_req -in kafka1.csr -CA ca.pem -CAkey ca.key -CAcreateserial -CAserial 1 -out kafka1.pem

# client_cdg Private Key and Certificates
openssl genrsa -aes256 -passout pass:Temporal0 -out client_cdg.pass.key 4096
openssl rsa -passin pass:Temporal0 -in client_cdg.pass.key -out client_cdg.key
rm client_cdg.pass.key
openssl req -config ca.conf -new -key client_cdg.key -out client_cdg.csr -subj "/C=ES/ST=Madrid/O=Cisco/L=Alcobendas/CN=kafka"
openssl x509 -req -days 730 -sha256 -extfile ca.conf -extensions v3_req -in client_cdg.csr -CA ca.pem -CAkey ca.key -CAcreateserial -CAserial 1 -out client_cdg.pem
openssl pkcs8 -topk8 -inform PEM -outform PEM -in client_cdg.key -out client_cdg.pkcs8.withpass.key -passout pass:Temporal0
keytool -keystore client_cdg.truststore.jks -alias CAROOT -import -file ca.pem -storepass Temporal0 -noprompt
openssl pkcs12 -export -in client_cdg.pem  -inkey client_cdg.key -out client_cdg.pfx -passout pass:Temporal0
keytool -importkeystore -deststorepass Temporal0 -destkeystore client_cdg.keystore.jks -srckeystore client_cdg.pfx -srcstoretype PKCS12 -noprompt -srcstorepass Temporal0

# Generate Keystore
openssl pkcs12 -export -in kafka1.pem  -inkey kafka1.key -out kafka1.pfx -passout pass:Temporal0
keytool -importkeystore -deststorepass Temporal0 -destkeystore kafka1.keystore.jks -srckeystore kafka1.pfx -srcstoretype PKCS12 -noprompt -srcstorepass Temporal0

# Generate Truststore
keytool -keystore server.truststore.jks -alias CAROOT -import -file ca.pem -storepass Temporal0 -noprompt
