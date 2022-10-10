#!/bin/bash
# (c) hacking y seguridad .com 2022
# Genera un autocertificado TLS
openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out certificado.crt -keyout clave.key
