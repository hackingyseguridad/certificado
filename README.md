

## Entidad certificadora (CA) inspección del Certificado:

Apertura/Importación del Certificado: El usuario abre o importa el archivo del certificado utilizando la herramienta elegida.
Visualización de los Detalles: La herramienta mostrará la información contenida en el certificado, que típicamente incluye:
Número de Serie: Un identificador único para ese certificado.
Emisor: El nombre de la Autoridad de Certificación (CA) que emitió el certificado.
Sujeto: La entidad (persona, organización, servidor) a la que se emitió el certificado.
Validez: Las fechas de inicio y fin de validez del certificado (caducidad).
Algoritmo de Firma: El algoritmo criptográfico utilizado para firmar el certificado.
Clave Pública: La clave pública asociada al certificado.
Huella Digital (Thumbprint): Un hash único del certificado, utilizado para su identificación.
Extensiones: Información adicional como el uso previsto del certificado.
Ruta de Certificación: La jerarquía de CAs que llevaron a la emisión del certificado.
4. Verificación Adicional (Opcional):

Lista de Certificados Revocados (CRL): Para comprobar si un certificado ha sido revocado antes de su fecha de caducidad, se puede consultar la CRL publicada por la CA emisora. La información sobre dónde encontrar la CRL suele estar incluida en el certificado.
Protocolo de Estado de Certificados en Línea (OCSP): Una alternativa a la CRL que permite realizar consultas en tiempo real sobre el estado de un certificado a un servidor OCSP de la CA. La información del servidor OCSP también puede estar incluida en el certificado.
Validación de la Cadena de Confianza: Es importante verificar que la cadena de certificación sea válida, es decir, que el certificado haya sido emitido por una CA en la que se confía (normalmente una CA raíz o una CA intermedia cuya firma está verificada por una CA raíz de confianza).

<img style="float:left" alt="Entidad Certificadora" src="https://github.com/hackingyseguridad/certificado/blob/master/ca.jpg">

Certificado Raíz:

El certificado raíz es un certificado auto-firmado emitido por una Autoridad de Certificación (CA) para identificarse a sí misma. Es el punto de partida de una cadena de confianza. Los navegadores y sistemas operativos confían implícitamente en los certificados raíz de las CAs reconocidas. Cuando un certificado de usuario o de servidor es emitido por una CA, su validez se verifica rastreando la cadena de certificación hasta el certificado raíz de confianza. El certificado raíz contiene la clave pública de la CA, que se utiliza para verificar las firmas de los certificados que emite.

Certificado de Cliente:

Un certificado de cliente es un tipo de certificado digital que se utiliza para identificar y autenticar a un cliente (un usuario, una aplicación o un dispositivo) cuando intenta acceder a un servidor o servicio. A diferencia de los certificados de servidor, que autentican el servidor ante el cliente, los certificados de cliente autentican al cliente ante el servidor. Se utilizan a menudo en escenarios donde se requiere una autenticación fuerte y mutua, como el acceso a redes privadas virtuales (VPNs), aplicaciones empresariales o servicios web restringidos. También se utilizan para firmar y cifrar correos electrónicos (certificados S/MIME).


Scripts para generar auto certificado digital 

# certificado

Generate CA key & autocertificado con generacert.sh

## Instalación OpenSSL
sudo apt-get install openssl

## Generar formato PEM fichero con clave privada MyRootCA.key 
openssl genrsa -out MyRootCA.key 2048

## Generar a partir de la clave privada en MyRootCA el fichero con clave publica MyRootCA.pem
openssl req -x509 -new -nodes -key MyRootCA.key -sha256 -days 1024 -out MyRootCA.pem

## Convertir MyRootCA.pem en MyRootCA.crt para Windows
openssl x509 -outform der -in MyRootCA.pem -out MyRootCA.crt

## Convertir MyRootCA.key en MyRootCA.csr (Solicitud de Firmar un Certificado)
openssl req -new -key MyRootCA.key -out MyRootCA.csr

# Convertir MyRootCA.pem en MyRootCA.der
openssl x509 -outform der -in MyRootCA.pem -out MyRootCA.der

# Convertir MyRootCA.pem en y clave privada a PKCS#12 (.pfx .p12)
openssl pkcs12 -export -out MyRootCA.pfx -inkey MyRootCA.key -in MyRootCA.crt -certfile CACert.crt

# Check Certificado:
openssl s_client -connect https://www.hackingyseguridad.com:443 |grep Verification

#Reemplace la variable const CA_CERT con el contenido del archivo MyRootCA.pem y la constante CA_CERT_KEY con el contenido de MyRootCA.key en el archivo 'plugin / autocert.go'.

#Instale y establezca el nivel de confianza correcto para la CA 'MyRootCA' en el almacén de certificados de su navegador.

# Tipos de extensiones en ficheros de certificados

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
