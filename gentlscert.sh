#!/bin/sh
# Genera un autocertificado TLS
openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out certificado.crt -keyout clave.key
