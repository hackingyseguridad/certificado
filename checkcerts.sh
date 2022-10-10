#!/bin/bash
# (c) hacking y seguridad .com 2022
# chequea informacion de un listado de fqdn
for n in `cat fqdn.txt`; do echo $n; openssl s_client -connect $n |grep Verification; done
