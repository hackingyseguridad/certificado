##  Certificado digital, recomendaciones de seguridad

| Certificado | Recomendación |
|---------------------|--------------------------|
| Comodín | El certificado debe ser emitido para la literalidad del FQDN nombre completo, evitando utilizar un mismo certificado como comodín para múltiples sitios con `*.dominio` (WildCard). |
| Vigencia | No debe superar 1 año (398 días o menos). Periodos largos (10-30 años) impiden la agilidad criptográfica y aumentan el riesgo de compromiso. |
| Entidad certificadora emisora (CA) | Debe ser emitido por una Autoridad de Certificación (CA) de confianza reconocida. Un certificado auto-firmado no ofrece una cadena de confianza verificable por terceros. Esto facilita los ataques de Man-in-the-Middle (MitM), ya que cualquier atacante puede generar su propio certificado auto-firmado y suplantar la identidad del servidor sin que el cliente tenga una forma automatizada de desconfiar. |
| Confianza | Al menos 3 niveles: CA Raíz (Root), CA Intermedia y Certificado Final (Leaf). |
| Validación | (path building y validación de extensiones) debe seguir estrictamente el estándar RFC 5280. |
| Revocación | Implementar verificación en tiempo real mediante OCSP (Online Certificate Status Protocol) o listas de revocación CRLs. |
| Protocolo | Implementar TLS bidireccional: tanto el servidor como el cliente deben presentar y validar sus respectivos certificados. TLS 1.2 o TLS 1.3. Se deben deshabilitar explícitamente SSLv2, SSLv3, TLS 1.0 y TLS 1.1. |
| Curva elíptica ECC | Uso de ECDSA con curvas seguras (ej. P-256 o P-384) como alternativa más eficiente y fuerte que RSA. |
| Key Exchange | Usar DHE o ECDHE (Forward Secrecy). No usar PSK (claves pre-compartidas), ni RSA 1024/DH/ECDH estáticos. La clave privada debe estar cifrada (AES-256). Usar claves públicas con fortaleza superior a 112 bits. Para categoría ALTA del ENS o sistemas clasificados, usar una fortaleza superior a 128 bits (RSA ≥ 3072 bits, ECDSA ≥ 256 bits). Longitud mínima de 2048 bits. Se recomienda 4096 bits para máxima seguridad frente a la evolución del cómputo. |
| Negociación | Soporte obligatorio de la extensión Supported_Groups para negociar algoritmos de intercambio de llaves de forma segura. |
| Política de Rechazo | El cliente y el servidor deben abortar la conexión si el certificado está caducado, revocado o si no se puede verificar su estado. Revocación: Consultar al responder OCSP de la CA si el certificado ha sido marcado como "no válido" antes de su fecha de expiración. OCSP Stapling: OCSP firmada de la CA, evitando que el cliente tenga que contactar a la CA directamente. |
| Autenticación Web/SSH | Uso de certificados X.509v3 (RSA o ECDSA). La clave pública se envía al cliente (navegador) y la clave privada se queda en el servidor. |
| HSTS | HTTP Strict Transport Security. Una cabecera de servidor que obliga al navegador a comunicarse siempre vía HTTPS, desde el inicio, evitando ataques de downgrade y que alguien pueda interceptar el SNI. |



## Certificado digital 

Los certificados digitales permiten: verificar, certificar la identidad de una persona o servidor (evitando suplantaciones). El Certificado contiene una serie de datos como: Datos del titular (nombre, organización, etc.). Clave pública (para cifrado y verificación de firmas). Firma digital de la Entidad Certificadora que valida su autenticidad. Fecha de validez (vigencia del certificado). El certificado digital para ello debe ser emitido por una Entidad certificadora de confianza, publica o privada.

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

## Certificado Raíz:

El certificado raíz es un certificado auto-firmado emitido por una Autoridad de Certificación (CA) para identificarse a sí misma. Es el punto de partida de una cadena de confianza. Los navegadores y sistemas operativos confían implícitamente en los certificados raíz de las CAs reconocidas. Cuando un certificado de usuario o de servidor es emitido por una CA, su validez se verifica rastreando la cadena de certificación hasta el certificado raíz de confianza. El certificado raíz contiene la clave pública de la CA, que se utiliza para verificar las firmas de los certificados que emite.

## Certificado de Cliente:

Un certificado de cliente es un tipo de certificado digital que se utiliza para identificar y autenticar a un cliente (un usuario, una aplicación o un dispositivo) cuando intenta acceder a un servidor o servicio. A diferencia de los certificados de servidor, que autentican el servidor ante el cliente, los certificados de cliente autentican al cliente ante el servidor. Se utilizan a menudo en escenarios donde se requiere una autenticación fuerte y mutua, como el acceso a redes privadas virtuales (VPNs), aplicaciones empresariales o servicios web restringidos. También se utilizan para firmar y cifrar correos electrónicos (certificados S/MIME).

## Extensiones de certificados:

.CER o .CRT: Suelen ser certificados X.509 codificados en formato DER binario o en formato PEM (Base64 ASCII). A menudo contienen solo el certificado público y no la clave privada.
.CRT este fichero es el que contiene la parte pública y que al unirse al KEY, genera el certificado completo.

.PEM: (Privacy-Enhanced Mail) Es un formato de texto que utiliza la codificación Base64 para representar el certificado (y a veces la clave privada). Los archivos PEM están delimitados por líneas como -----BEGIN CERTIFICATE----- y -----END CERTIFICATE-----. Pueden contener un solo certificado, la cadena de certificados o la clave privada. Las extensiones .pem, .crt y .cer se usan a menudo indistintamente para archivos codificados en PEM.

.DER: (Distinguished Encoding Rules) Es una codificación binaria del estándar X.509. Los archivos con extensión .der generalmente contienen un solo certificado.

.P7B o .P7C: Son archivos PKCS#7 (Public-Key Cryptography Standards #7). Pueden contener uno o varios certificados (la cadena de confianza) pero no suelen incluir la clave privada.

.PFX o .P12: Son archivos PKCS#12. Este formato es un contenedor que puede almacenar tanto el certificado público como la clave privada asociada, y potencialmente la cadena de certificados. Suelen estar protegidos con una contraseña. Es un formato común para importar y exportar certificados en sistemas Windows y macOS.

.KEY: Aunque no es exclusivamente para certificados, esta extensión se utiliza comúnmente para almacenar claves privadas en formato PEM o DER. A veces puede contener también el certificado público.
.KEY son los que contienen la parte privada del certificado y que complementan la parte publica del CRT / CERT.

.CSR: (Certificate Signing Request) No es 

## Scripts para generar auto certificado digital 

## Generate CA key & autocertificado con generacert.sh

sh generacert.sh

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

## Convertir MyRootCA.pem en MyRootCA.der

openssl x509 -outform der -in MyRootCA.pem -out MyRootCA.der

## Convertir MyRootCA.pem en y clave privada a PKCS#12 (.pfx .p12)

openssl pkcs12 -export -out MyRootCA.pfx -inkey MyRootCA.key -in MyRootCA.crt -certfile CACert.crt

## Check Certificado:

openssl s_client -connect https://www.hackingyseguridad.com:443 |grep Verification

#Reemplace la variable const CA_CERT con el contenido del archivo MyRootCA.pem y la constante CA_CERT_KEY con el contenido de MyRootCA.key en el archivo 'plugin / 
autocert.go'.

#Instale y establezca el nivel de confianza correcto para la CA 'MyRootCA' en el almacén de certificados de su navegador.





#
http://www.hackingyseguridad.com/
#






