#!/bin/bash
# (c) hacking y seguridad .com 2022

# Instalación OpenSSL
sudo apt-get install openssl

# Generar formato PEM fichero con clave privada MyRootCA.key
openssl genrsa -out /etc/ssl/private/MyRootCA.key 3072

# Generar a partir de la clave privada en MyRootCA el fichero con clave publica MyRootCA.pem
openssl req -x509 -new -nodes -key /etc/ssl/private/MyRootCA.key -sha256 -days 3652 -out /etc/ssl/certs/MyRootCA.pem

# Convertir MyRootCA.pem en MyRootCA.crt para Windows
openssl x509 -outform der -in /etc/ssl/certs/MyRootCA.pem -out /etc/ssl/certs/MyRootCA.crt

# Convertir MyRootCA.pem en MyRootCA.der
openssl x509 -outform der -in /etc/ssl/certs/MyRootCA.pem -out /etc/ssl/certs/MyRootCA.der

# Copiamos los certificados en los repositorios:
# cp MyRootCA.pem /etc/ssl/certs/MyRootCA.pem
# cp MyRootCA.key /etc/ssl/private/MyRootCA.key
# cp MyRootCA.crt /etc/ssl/certs/MyRootCA.crt
