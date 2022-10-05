Scripts para generar auto certificado digital 

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


.key son los que contienen la parte privada del certificado y que complementan la parte publica del CRT / CERT.
.crt este fichero es el que contiene la parte pública y que al unirse al KEY, genera el certificado completo.
.pem puede contener múltiples secciones en caso de que sea necesario.

-----BEGIN PRIVATE KEY-----
//Nuestra KEY
-----END PRIVATE KEY-----
-----BEGIN CERTIFICATE-----
//Certificado intermedio del proveedor
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
//root
-----END CERTIFICATE-----
