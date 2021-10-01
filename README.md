# certificado

Generate CA key & autocertificado con generacert.sh

# Instalación OpenSSL
sudo apt-get install openssl

# Generar formato PEM fichero con clave privada MyRootCA.key 
openssl genrsa -out MyRootCA.key 2048

# Generar a partir de la clave privada en MyRootCA el fichero con clave publica MyRootCA.pem
openssl req -x509 -new -nodes -key MyRootCA.key -sha256 -days 1024 -out MyRootCA.pem

# Convertir MyRootCA.pem en MyRootCA.crt para Windows
openssl x509 -outform der -in MyRootCA.pem -out MyRootCA.crt

# Convertir MyRootCA.key en MyRootCA.csr (Solicitud de Firmar un Certificado)
openssl req -new -key MyRootCA.key -out MyRootCA.csr

# Convertir MyRootCA.pem en MyRootCA.der
openssl x509 -outform der -in MyRootCA.pem -out MyRootCA.der

# Convertir MyRootCA.pem en y clave privada a PKCS#12 (.pfx .p12)
openssl pkcs12 -export -out MyRootCA.pfx -inkey MyRootCA.key -in MyRootCA.crt -certfile CACert.crt

# Check Certificado:
openssl s_client -connect https://www.hackingyseguridad.com:443 |grep Verification

#Reemplace la variable const CA_CERT con el contenido del archivo MyRootCA.pem y la constante CA_CERT_KEY con el contenido de MyRootCA.key en el archivo 'plugin / autocert.go'.

#Instale y establezca el nivel de confianza correcto para la CA 'MyRootCA' en el almacén de certificados de su navegador.
