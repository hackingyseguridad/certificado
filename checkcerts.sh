# chequea informacion de un listado de fqdn

#!/bin/bash
for n in `cat fqdn.txt`; do echo $n; openssl s_client -connect $n |grep Verification; done
