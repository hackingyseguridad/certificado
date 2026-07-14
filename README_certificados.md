### Certificados digitales - PKI y CA

> **certificados digitales, autoridades certificadoras (CA), infraestructura PKI y generación segura de certificados X.509.**

### Tabla de Contenidos

- [Introducción](#introducción)
- [Certificado Digital](#qué-es-un-certificado-digital)
- [Tipos de Certificados](#tipos-de-certificados)
- [Infraestructura PKI (Public Key Infrastructure)](#infraestructura-pki)
- [Extensiones y Formatos](#extensiones-y-formatos)
- [Recomendaciones de Seguridad](#recomendaciones-de-seguridad)
- [Guía Paso a Paso](#guía-paso-a-paso)
- [Scripts Disponibles](#scripts-disponibles)
- [Herramientas OpenSSL](#herramientas-openssl)
- [Validación y Verificación](#validación-y-verificación)
- [Cadena de Certificados](#cadena-de-certificados)
- [Revocación de Certificados](#revocación-de-certificados)
- [Post-Cuántico](#post-cuántico)
- [Referencias](#referencias)

---

### Introducción:

Los certificados digitales son documentos electrónicos que:

**Verifican identidades** - Aseguran que eres quien dices ser  
**Cifran datos** - Protegen información mediante criptografía  
**Firman digitalmente** - Garantizan integridad y no-rechazo  
**Establecen confianza** - Crear cadenas de confianza verificables  

### Objetivos de Este Repositorio

1. **Entender** la estructura y funcionamiento de certificados X.509
2. **Generar** certificados de forma segura (CA, servidores, clientes)
3. **Implementar** infraestructura PKI confiable
4. **Auditar** certificados existentes
5. **Mantener** y renovar certificados
6. **Prepararse** para criptografía post-cuántica

---

### Certificado Digital

### Componentes

Un certificado digital es un archivo que contiene:

| Componente | Descripción | Ejemplo |
|-----------|-------------|---------|
| **Número de Serie** | Identificador único del certificado | `01:AB:CD:EF` |
| **Sujeto** | Entidad a quien se emite (Common Name - CN) | `CN=ejemplo.com` |
| **Emisor** | CA que firma el certificado | `CN=CA Raíz` |
| **Validez (Desde)** | Fecha de emisión | `01/01/2024` |
| **Validez (Hasta)** | Fecha de expiración | `01/01/2025` |
| **Clave Pública** | Clave para cifrado/verificación | RSA 2048 bits |
| **Firma Digital** | Firma de la CA validando el cert | SHA-256 + RSA |
| **Extensiones** | Información adicional (SAN, EKU, etc.) | `subjectAltName` |
| **Huella Digital** | Hash único del certificado | SHA-256 |

### Estructura Jerárquica de PKI

```
                    ┌─────────────────┐
                    │  CA Raíz (Root) │
                    │  (Auto-Firmada) │
                    └────────┬────────┘
                             │
           ┌─────────────────┼─────────────────┐
           │                 │                 │
      ┌────────┐      ┌────────────┐      ┌────────┐
      │ CA Int1│      │ CA Int2    │      │ CA Int3│
      │ (Cert) │      │ (Cert)     │      │ (Cert) │
      └────┬───┘      └────┬───────┘      └────┬───┘
           │               │                    │
      ┌────────┐      ┌─────────┐          ┌────────┐
      │ Server │      │ Client  │          │ Email  │
      │  Cert  │      │  Cert   │          │ Cert   │
      └────────┘      └─────────┘          └────────┘
```

---

### Tipos de certificados

### Certificados de Servidor

Se usan para autenticar servidores web, mail, VPN, etc.

| Tipo | Uso | Validación | Confianza | Costo |
|------|-----|-----------|----------|-------|
| **DV** (Domain Validated) | Pequeños sitios web | Solo dominio | Baja | Gratis-$10 |
| **OV** (Organization Validated) | Empresas medianas | Dominio + Organización | Media | $50-$100 |
| **EV** (Extended Validation) | E-commerce, Banca | Completa verificación | Alta | $100-$300 |
| **Wildcard** | Múltiples subdominios | `*.ejemplo.com` | Según validación | +$20-50 |
| **SAN/UCC** | Múltiples dominios | Varios dominios | Según validación | +$10-30 |

**Características DV (Let's Encrypt)**:
```
Validación automática
Renovación automática cada 90 días
Gratis y confiable
Ideal para desarrolladores
No verifica organización
```

###  Certificados de Cliente

Autentican usuarios o aplicaciones en conexiones TLS mutuas.

| Aspecto | Detalle |
|--------|--------|
| **Uso** | Autenticación mutua TLS, VPN, acceso SSH |
| **Validación** | Depende del emisor (puede ser auto-firmado) |
| **Confianza** | Necesita configuración en servidor |
| **Renovación** | Manual o automática según CA |
| **S/MIME** | Firma y cifrado de correos electrónicos |

### Certificados Auto-Firmados

Certificados donde el emisor es el propietario.

| Característica | Valor |
|----------------|-------|
| **Firma de** | Sí mismo (auto-firmware) |
| **Cadena de confianza** | No existe (root = sí mismo) |
| **Validación automática** |  No (navegador advierte) |
| **Seguridad MitM** |  Vulnerable sin validación manual |
| **Uso** | Testing, desarrollo, infraestructura privada |
| **Ventaja** | Gratis, rápido, sin dependencias |
| **Desventaja** | No proporciona confianza a terceros |

**IMPORTANTE**: Nunca usar auto-firmados en producción con exposicion publica.

### Certificados Especiales

| Tipo | Descripción | Casos de Uso |
|------|-------------|------------|
| **Subject Alt Name (SAN)** | Múltiples names en un certificado | www.ejemplo.com, ejemplo.com, api.ejemplo.com |
| **Wildcard (*)** | Cubre todos los subdominios | `*.ejemplo.com` cubre test.ejemplo.com, prod.ejemplo.com |
| **Code Signing** | Firma código/ejecutables | Aplicaciones Windows, macOS |
| **Timestamp** | Marca temporal verificada | Firma documentos electrónicos |
| **OCSP Responder** | Verifica revocación en tiempo real | OCSP Stapling en servidores |
| **Time Stamping Authority** | Prueba de existencia temporal | Sellado de tiempo notarial |

---

### Infraestructura PKI

### Componentes de una PKI Completa

```
┌─────────────────────────────────────────────────────────────┐
│              PUBLIC KEY INFRASTRUCTURE (PKI)                 │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ CA RAÍZ (Root CA)                                    │  │
│  │ - Auto-firmado                                       │  │
│  │ - Máxima confianza                                   │  │
│  │ - Mantener OFFLINE                                   │  │
│  └──────────────────────────────────────────────────────┘  │
│                      ↓                                      │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ CA INTERMEDIA (Intermediate CA)                      │  │
│  │ - Firmada por Root CA                                │  │
│  │ - Emite certificados leaf                            │  │
│  │ - Puede estar ONLINE                                 │  │
│  └──────────────────────────────────────────────────────┘  │
│                      ↓                                      │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ CERTIFICADOS LEAF (Servidor, Cliente, Email)        │  │
│  │ - Emitidos por CA Intermedia                         │  │
│  │ - Firmados con clave privada de CA                   │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ COMPONENTES DE SOPORTE                               │  │
│  │ - CRL (Certificate Revocation List)                  │  │
│  │ - OCSP (Online Certificate Status Protocol)          │  │
│  │ - Repositorio de certificados                        │  │
│  │ - Timestamping Authority                             │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Niveles de Confianza Recomendados

| Nivel | Descripción | Seguridad | Ejemplo |
|-------|-------------|----------|---------|
| **1 Nivel** | Certificado auto-firmado solo | 🔴 Baja | Testing local |
| **2 Niveles** | Root → Certificado | 🟠 Media | Pequeñas empresas |
| **3 Niveles** | Root → Intermedia → Certificado | 🟢 Alta | Recomendado estándar |
| **4 Niveles** | Root → Sub-Int1 → Sub-Int2 → Certificado | 🟢 Muy Alta | Grandes organizaciones |

**Recomendación Mínima: 3 Niveles**

---

### Extensiones y Formatos

### Formatos de Certificados

| Extensión | Formato | Codificación | Contenido | Soporte |
|-----------|---------|--------------|----------|---------|
| **.pem** | PEM | Base64 ASCII | Cert + opcional clave privada | 🌍 Universal |
| **.crt** | X.509 | PEM o DER | Solo certificado público | 🌍 Universal |
| **.cer** | X.509 | PEM o DER | Solo certificado público | Windows/Unix |
| **.der** | X.509 | Binario | Certificado (no legible en texto) | Sistemas legacy |
| **.pfx** | PKCS#12 | Binario | Cert + clave privada + CA chain | Windows/macOS |
| **.p12** | PKCS#12 | Binario | Igual a .pfx (alias) | macOS/Linux |
| **.p7b** | PKCS#7 | ASCII | Cadena de certificados | Windows |
| **.p7c** | PKCS#7 | ASCII | Igual a .p7b | Windows |
| **.key** | PEM | Base64 ASCII | Clave privada (NO certificado) | 🌍 Universal |
| **.csr** | PKCS#10 | PEM | Solicitud de firma de certificado | 🌍 Universal |
| **.jks** | Java | Binario | Almacén de certificados Java | Java solo |

### Estructura de Archivo PEM

```
-----BEGIN CERTIFICATE-----
MIIFWzCCA0OgAwIBAgIUK7Y4N5R9Sv7Fz8qJ...
(base64 encoded certificate data)
...
V3kLzQkJIhZ7tTvQGZL0QmZoqiM=
-----END CERTIFICATE-----

-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCA...
(base64 encoded private key data)
...
kJOy3S7qhHZ1yI8xFxdR=
-----END PRIVATE KEY-----
```

### Archivo KEY

```
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA1234567890...
(base64 encoded private key)
...
-----END RSA PRIVATE KEY-----
```

### Archivo CSR (Certificate Signing Request)

```
-----BEGIN CERTIFICATE REQUEST-----
MIICkzCCAXsCAQAwRTELMAkGA1UEBhMCQVU...
(base64 encoded CSR data)
...
-----END CERTIFICATE REQUEST-----
```

---

### Recomendaciones de seguridad

### Matriz de algoritmo y tamaño de clave

| Contexto | Algoritmo | Tamaño | Validez | OCSP | Recomendación |
|----------|-----------|--------|---------|------|---|
| **HTTPS Público** | RSA | ≥2048 | 1 año |  Sí | Use Let's Encrypt (gratuito) |
| **HTTPS Público** | ECDSA | P-256+ | 1 año |  Sí |  Mejor que RSA (más rápido) |
| **SSH Servidor** | Ed25519 | 256 bits | N/A | N/A |  Óptimo |
| **Base de Datos** | RSA | ≥2048 | 2-3 años |  Sí | Si es TLS |
| **VPN/IPsec** | ECDSA | P-256+ | 1-2 años |  Sí |  Recomendado |
| **Cliente TLS Mutuo** | RSA | ≥2048 | 1 año | Opcional | Validación servidor necesaria |
| **Firma Código** | RSA | ≥3072 | 3 años |  Sí | Timestamp obligatorio |
| **Correo S/MIME** | RSA | ≥2048 | 1-3 años |  Opcional | Validación de identidad |

### Tabla de recomendaciones de seguridad (ENS nivel alto)

| Aspecto | Recomendación | Mínimo | Óptimo | Por qué |
|--------|---------------|--------|---------|---------|
| **Vigencia** | ≤1 año (90 días recomendado) | 1 año | 90 días | Agilidad criptográfica |
| **Nombre** | Literalidad del FQDN | - | CN=ejemplo.com | Evitar wildcard riesgoso |
| **CA Emisora** | Reconocida y confiable | - | Let's Encrypt, Sectigo, DigiCert | Evita MitM |
| **Niveles Confianza** | Mínimo 3 | 2 | 4 | Seguridad en profundidad |
| **Algoritmo Firma** | SHA-256+ | - | SHA-384/512 | SHA-1 deprecated |
| **Algoritmo Clave** | RSA ≥2048 o ECDSA P-256+ | RSA 2048 | ECDSA P-384 o RSA 4096 | RSA<2048 vulnerable |
| **Key Exchange** | ECDHE/DHE (PFS) | - | ECDHE-P384 | Evita compromiso histórico |
| **Validación Cliente** | RFC 5280 path building | - | Strict | Mitiga ataques cadena |
| **Revocación** | OCSP Stapling | CRL | OCSP Stapling | Rendimiento + seguridad |
| **Protocolo TLS** | TLS 1.2+ | TLS 1.2 | TLS 1.3 | Elimina debilidades |
| **Clave Privada** | Cifrada AES-256 | Sí | AES-256 | Protección en disco |
| **Hardware de Clave** | HSM/TPM si clasif. | Opcional | Sí | Máxima seguridad |

### NO Hacer

| Configuración | Riesgo | Alternativa |
|---------------|--------|------------|
| **Certificado comodín `*.com`** | 🔴 CRÍTICO | Usar dominios específicos |
| **Validez > 2 años** | 🔴 CRÍTICO | Renovación anual |
| **RSA < 2048 bits** | 🔴 CRÍTICO | RSA 2048 mínimo |
| **Auto-firmado en producción** | 🔴 CRÍTICO | Usar CA confiable |
| **SHA-1 en certificado** | 🔴 CRÍTICO | SHA-256 o superior |
| **DES/3DES para cifrar privada** | 🔴 CRÍTICO | AES-256 |
| **Sin OCSP ni CRL** | 🟠 ALTO | Implementar revocación |
| **TLS 1.0/1.1** | 🟠 ALTO | TLS 1.2 o 1.3 |
| **RSA estático (sin PFS)** | 🟠 ALTO | ECDHE o DHE |
| **Certificado sin SAN** | 🟠 MEDIO | Añadir SAN |

---

### Guía Paso a Paso

### Crear CA Raíz (Autoridad Certificadora)

#### Paso 1: Generar clave privada RSA (2048 bits)

```bash
openssl genrsa -out ca.key 2048
```

**Salida esperada**:
```
Generating RSA private key, 2048 bit long modulus
.+++
.+++
e is 65537 (0x10001)
```

**Archivo generado**: `ca.key` (clave privada)

#### Paso 2: Crear certificado raíz auto-firmado (válido 10 años)

```bash
openssl req -x509 -new -nodes \
  -key ca.key \
  -sha256 \
  -days 3650 \
  -out ca.crt \
  -subj "/C=ES/ST=Madrid/L=Madrid/O=Hacking y Seguridad/CN=CA Raiz Hacking y Seguridad"
```

**Parámetros**:
- `-x509` - Crear certificado X.509 auto-firmado
- `-new` - Nueva solicitud
- `-sha256` - Usar SHA-256 para firma
- `-days 3650` - Válido 10 años
- `-subj` - Datos directos (sin prompt interactivo)

**Archivo generado**: `ca.crt` (certificado raíz público)

**Verificar certificado**:
```bash
openssl x509 -in ca.crt -text -noout
```

### Crear Certificado Intermedio

#### Paso 1: Generar clave privada

```bash
openssl genrsa -out intermediate.key 2048
```

#### Paso 2: Crear CSR (Certificate Signing Request)

```bash
openssl req -new \
  -key intermediate.key \
  -out intermediate.csr \
  -subj "/C=ES/ST=Madrid/L=Madrid/O=Hacking y Seguridad/CN=CA Intermedia"
```

#### Paso 3: Crear archivo de extensiones

```bash
cat > intermediate.ext << EOF
basicConstraints=CA:TRUE,pathlen:0
keyUsage=critical,keyCertSign,cRLSign
EOF
```

#### Paso 4: Firmar con CA raíz

```bash
openssl x509 -req \
  -in intermediate.csr \
  -CA ca.crt \
  -CAkey ca.key \
  -CAcreateserial \
  -out intermediate.crt \
  -days 3650 \
  -sha256 \
  -extfile intermediate.ext
```

**Archivo generado**: `intermediate.crt` (certificado intermedio)

### Crear Certificado de Servidor

#### Paso 1: Generar clave privada

```bash
openssl genrsa -out server.key 2048
```

#### Paso 2: Crear CSR

```bash
openssl req -new \
  -key server.key \
  -out server.csr \
  -subj "/C=ES/ST=Madrid/L=Madrid/O=Hacking y Seguridad/CN=ejemplo.com"
```

#### Paso 3: Crear archivo de extensiones (SAN)

```bash
cat > server.ext << EOF
subjectAltName=DNS:ejemplo.com,DNS:www.ejemplo.com,DNS:api.ejemplo.com
keyUsage=critical,digitalSignature,keyEncipherment
extendedKeyUsage=serverAuth
EOF
```

#### Paso 4: Firmar con CA intermedia

```bash
openssl x509 -req \
  -in server.csr \
  -CA intermediate.crt \
  -CAkey intermediate.key \
  -CAcreateserial \
  -out server.crt \
  -days 365 \
  -sha256 \
  -extfile server.ext
```

**Archivos generados**:
- `server.key` - Clave privada (GUARDAR SEGURO)
- `server.crt` - Certificado servidor

###  Crear Certificado de Cliente

#### Paso 1: Generar clave privada

```bash
openssl genrsa -out client.key 2048
```

#### Paso 2: Crear CSR

```bash
openssl req -new \
  -key client.key \
  -out client.csr \
  -subj "/C=ES/ST=Madrid/L=Madrid/O=Hacking y Seguridad/CN=usuario@ejemplo.com"
```

#### Paso 3: Crear extensiones

```bash
cat > client.ext << EOF
keyUsage=critical,digitalSignature,keyEncipherment
extendedKeyUsage=clientAuth
EOF
```

#### Paso 4: Firmar con CA intermedia

```bash
openssl x509 -req \
  -in client.csr \
  -CA intermediate.crt \
  -CAkey intermediate.key \
  -CAcreateserial \
  -out client.crt \
  -days 365 \
  -sha256 \
  -extfile client.ext
```

### Crear Cadena de Certificados

Combinar certificados para presentar al cliente:

```bash
# Cadena completa (para servidor)
cat intermediate.crt ca.crt > ca-chain.crt

# O en un solo PEM
cat server.crt intermediate.crt ca.crt > fullchain.pem
```

### Conversiones de Formato

#### PEM → DER (binario)

```bash
openssl x509 -in certificado.pem -outform DER -out certificado.der
```

#### PEM + KEY → PKCS#12 (.pfx)

```bash
openssl pkcs12 -export \
  -out certificado.pfx \
  -inkey server.key \
  -in server.crt \
  -certfile ca-chain.crt \
  -password pass:contraseña123
```

#### PKCS#12 → PEM

```bash
openssl pkcs12 -in certificado.pfx -out certificado.pem -nodes
```

---

### Scripts Disponibles

### 🔧 Script: generacert.sh

**Descripción**: Genera CA raíz y certificado auto-firmado automáticamente.

**Uso**:
```bash
sh generacert.sh
```

**Qué genera**:
- `MyRootCA.key` - Clave privada CA (2048 bits)
- `MyRootCA.pem` - Certificado CA (formato PEM)
- `MyRootCA.crt` - Certificado CA (formato DER para Windows)

**Parámetros configurables**:
- Tamaño clave: 2048 bits (por defecto)
- Validez: 1024 días (configurable)
- Algoritmo firma: SHA-256

### 🔧 Script: gencerts.sh

**Descripción**: Genera múltiples certificados (CA, servidor, cliente).

**Uso**:
```bash
sh gencerts.sh
```

**Genera**:
- CA Root
- CA Intermedia
- Certificado de servidor
- Certificado de cliente
- Cadenas de certificados

### 🔧 Script: gentlscert.sh

**Descripción**: Genera certificados TLS específicos para servidores.

**Uso**:
```bash
sh gentlscert.sh ejemplo.com
```

**Genera**:
- Clave privada servidor
- Certificado servidor con SAN
- CSR para firma por CA externa

### 🔧 Script: checkcerts.sh

**Descripción**: Verifica certificados existentes.

**Uso**:
```bash
sh checkcerts.sh archivo.crt
```

**Información proporcionada**:
- Sujeto y emisor
- Fechas de validez
- Algoritmos utilizados
- Extensiones presentes
- Estado de revocación

### 🔧 Script: curlssl.sh

**Descripción**: Prueba certificados en conexiones HTTPS.

**Uso**:
```bash
sh curlssl.sh https://ejemplo.com
```

**Verifica**:
- Validez del certificado
- Cadena de confianza
- Extensiones TLS
- Protocolos soportados

### 🔧 Script: tlsx.sh

**Descripción**: Análisis detallado de TLS en servidor remoto.

**Uso**:
```bash
sh tlsx.sh ejemplo.com:443
```

**Analiza**:
- Versiones TLS soportadas
- Cifrados disponibles
- Certificados presentados
- Vulnerabilidades conocidas

### 🔧 Script: verifica_ca.sh

**Descripción**: Verifica la validez de una CA y su cadena.

**Uso**:
```bash
sh verifica_ca.sh ca.crt
```

**Verifica**:
- Auto-firma (si aplica)
- Cadena de confianza
- Extensiones basicConstraints
- Claves válidas

### 🔧 Script: instalar.sh

**Descripción**: Instala dependencias necesarias (OpenSSL, herramientas).

**Uso**:
```bash
sudo sh instalar.sh
```

**Instala en**:
- Ubuntu/Debian: openssl, curl, git
- CentOS/RHEL: openssl, curl, git
- macOS: openssl via brew

---

### Herramientas OpenSSL

###  Comandos Esenciales

#### Ver detalles de un certificado

```bash
openssl x509 -in cert.pem -text -noout
```

**Información mostrada**:
- Version, Serial Number
- Issuer (CA que lo emitió)
- Subject (a quién pertenece)
- Public Key info (tipo, tamaño)
- Validity (desde-hasta)
- Signature Algorithm
- Extensions (SAN, EKU, etc.)
- Thumbprint

#### Verificar cadena de certificados

```bash
openssl verify -CAfile ca.pem cert.pem
```

**Salida**:
- `cert.pem: OK` - Cadena válida
- `error 20 at depth 0` - Certificado no es CA raíz

#### Extraer información de CSR

```bash
openssl req -in cert.csr -text -noout
```

#### Convertir certificado a texto legible

```bash
openssl x509 -in cert.crt -outform DER -out cert.der
```

#### Verificar clave privada

```bash
openssl rsa -in private.key -check
```

#### Extraer clave pública de privada

```bash
openssl rsa -in private.key -pubout -out public.key
```

#### Verificar que clave privada coincide con certificado

```bash
# Comparar módulos (deben ser iguales)
openssl x509 -noout -modulus -in cert.crt | openssl md5
openssl rsa -noout -modulus -in private.key | openssl md5
```

#### Conectar a servidor TLS y ver certificado

```bash
openssl s_client -connect ejemplo.com:443 -showcerts
```

**Información proporcionada**:
- Certificado presentado
- Cadena de certificados
- Versión TLS usada
- Cifrado negociado
- Información de sesión

#### Firmar con certificado (ejemplo)

```bash
openssl dgst -sha256 -sign private.key datos.txt > firma.sig
```

#### Verificar firma

```bash
openssl dgst -sha256 -verify public.key -signature firma.sig datos.txt
```

###  Tabla de Comandos OpenSSL Comunes

| Tarea | Comando | Archivo Input | Archivo Output |
|-------|---------|---------------|----------------|
| Generar clave RSA | `openssl genrsa -out key.key 2048` | - | `.key` |
| Generar ECDSA | `openssl ecparam -name prime256v1 -genkey -out key.ec` | - | `.ec` |
| Crear CSR | `openssl req -new -key key.key -out cert.csr` | `.key` | `.csr` |
| Auto-firmar | `openssl req -x509 -key key.key -days 365 -out cert.crt` | `.key` | `.crt` |
| Ver certificado | `openssl x509 -in cert.crt -text -noout` | `.crt` | Terminal |
| Ver CSR | `openssl req -in cert.csr -text -noout` | `.csr` | Terminal |
| Ver clave privada | `openssl rsa -in key.key -text -noout` | `.key` | Terminal |
| Convertir PEM→DER | `openssl x509 -in cert.pem -outform DER -out cert.der` | `.pem` | `.der` |
| Convertir DER→PEM | `openssl x509 -in cert.der -inform DER -out cert.pem` | `.der` | `.pem` |
| Convertir a PKCS12 | `openssl pkcs12 -export -in cert.crt -inkey key.key -out cert.pfx` | `.crt`, `.key` | `.pfx` |
| Extraer de PKCS12 | `openssl pkcs12 -in cert.pfx -out cert.pem -nodes` | `.pfx` | `.pem` |
| Verify certificado | `openssl verify -CAfile ca.pem cert.pem` | `.pem` | Terminal |
| Ver cadena TLS | `openssl s_client -connect ejemplo.com:443 -showcerts` | - | Terminal |

---

### Validación 

### Validar un certificado

#### 1. Verificar que está dentro de vigencia

```bash
openssl x509 -in cert.pem -noout -dates
```

**Salida**:
```
notBefore=Jan  1 00:00:00 2024 GMT
notAfter=Jan  1 00:00:00 2025 GMT
```

#### 2. Comprobar que la clave privada coincide

```bash
# Calcular MD5 de módulo RSA
openssl x509 -noout -modulus -in cert.crt | openssl md5
openssl rsa -noout -modulus -in cert.key | openssl md5
# Deben ser idénticos
```

#### 3. Validar cadena de confianza

```bash
openssl verify -CAfile ca-bundle.pem -untrusted intermediate.pem cert.pem
```

#### 4. Verificar extensiones críticas

```bash
openssl x509 -in cert.pem -text -noout | grep -A5 "X509v3 extensions"
```

**Extensiones importantes**:
- `basicConstraints` - Si es CA o Leaf
- `keyUsage` - Uso de clave (digitalSignature, keyEncipherment, etc.)
- `extendedKeyUsage` - Uso específico (serverAuth, clientAuth, etc.)
- `subjectAltName` - Nombres alternativos
- `authorityKeyIdentifier` - ID clave de la CA
- `subjectKeyIdentifier` - ID clave del certificado

### Auditar Certificado (Checklist)

```bash
#!/bin/bash
# Script de auditoría de certificado

CERT="cert.pem"

echo "=== AUDITORÍA DE CERTIFICADO ==="

echo -e "\n1. Sujeto y Emisor:"
openssl x509 -in $CERT -noout -subject -issuer

echo -e "\n2. Validez:"
openssl x509 -in $CERT -noout -dates

echo -e "\n3. Tamaño de clave:"
openssl x509 -in $CERT -noout -text | grep "Public-Key"

echo -e "\n4. Algoritmo de firma:"
openssl x509 -in $CERT -noout -text | grep "Signature Algorithm"

echo -e "\n5. Extensiones SAN:"
openssl x509 -in $CERT -noout -text | grep -A1 "Subject Alternative Name"

echo -e "\n6. Huella digital (SHA-256):"
openssl x509 -in $CERT -noout -fingerprint -sha256

echo -e "\n7. Verificación de cadena:"
openssl verify -CAfile ca.pem $CERT && echo "✅ Cadena válida" || echo "❌ Cadena inválida"
```

---

### Cadena de Certificados

### 🔗 Estructura de una Cadena Válida

```
Certificado Leaf
    ↑
    │ Firmado por
    │
CA Intermedia
    ↑
    │ Firmado por
    │
CA Raíz (Trusted)
```

### Crear cadena completa

```bash
# Orden correcto: Leaf → Intermediate → Root
cat server.crt intermediate.crt ca.crt > chain.pem

# Para Apache (servidor + cadena)
cat server.crt intermediate.crt > bundle.pem
```

###  Validar cadena

```bash
openssl verify -CAfile ca.crt -untrusted intermediate.crt server.crt
```

**Salida correcta**: `server.crt: OK`

### Verificar cadena en servidor web

#### Apache

```apache
SSLCertificateFile /path/to/server.crt
SSLCertificateKeyFile /path/to/server.key
SSLCertificateChainFile /path/to/chain.pem
```

#### Nginx

```nginx
ssl_certificate /path/to/chain.pem;
ssl_certificate_key /path/to/server.key;
```

#### HAProxy

```
bind :443 ssl crt /path/to/server.pem
# En server.pem: server.crt + server.key + intermediate.crt
```

---

### Revocación de Certificados

### Metodos de revocación

| Método | Tipo | Latencia | Complejidad | Uso |
|--------|------|----------|------------|-----|
| **CRL** | File | ~Diaria | Media | Traditional |
| **OCSP** | Query | ~Minutos | Alta | Moderno |
| **OCSP Stapling** | Cached | ~Minutos | Muy Alta | Óptimo |

###  Revocar un certificado

#### Paso 1: Crear base de datos de revocación (CA)

```bash
# Crear directorio de CA
mkdir -p ca/certs ca/crl ca/newcerts
touch ca/index.txt
echo "01" > ca/serial
echo "01" > ca/crlnumber
```

#### Paso 2: Revocar certificado

```bash
openssl ca -revoke cert_to_revoke.pem \
  -keyfile ca.key \
  -cert ca.crt \
  -config openssl.cnf
```

#### Paso 3: Generar CRL (Certificate Revocation List)

```bash
openssl ca -gencrl \
  -keyfile ca.key \
  -cert ca.crt \
  -out ca.crl \
  -config openssl.cnf
```

#### Paso 4: Ver CRL

```bash
openssl crl -in ca.crl -text -noout
```

### Verificar revocación

#### Mediante CRL

```bash
openssl verify -CAfile ca.pem -crl_check cert.pem
```

#### Mediante OCSP

```bash
# Obtener URL OCSP del certificado
openssl x509 -in cert.pem -noout -ocsp_uri

# Consultar estado OCSP
openssl ocsp -issuer ca.pem -cert cert.pem -url http://ocsp.ca.com
```

**Posibles respuestas**:
- `good` - Certificado válido
- `revoked` - Certificado revocado
- `unknown` - Estado desconocido

---

### Post-Cuántico

### Algoritmos post-cuanticos recomendados

| Algoritmo | Tipo | Tamaño | Estado | Recomendación |
|-----------|------|--------|--------|--|
| **ML-KEM-768** (Kyber) | KEX | 768 bits | 🟢 NIST 2024 | Media |
| **ML-KEM-1024** | KEX | 1024 bits | 🟢 NIST 2024 | Alta |
| **ML-DSA** (Dilithium) | Firma | 2544 bytes | 🟢 NIST 2024 | Recomendado |
| **SLH-DSA** (SPHINCS+) | Firma | Variable | 🟢 NIST 2024 | Stateless |
| **Falcon** | Firma | 897 bytes | 🟢 NIST 2024 | Compacto |

###  Estrategia de Migración

**Fase 1 (2024-2025)**: Algoritmos clásicos fortalecidos
```bash
# Usar ECDSA P-384 en lugar de RSA-2048
openssl req -new -x509 \
  -keyout key.ec \
  -out cert.ec \
  -nodes \
  -subj "/C=ES/O=Org/CN=ejemplo.com"
```

**Fase 2 (2025-2026)**: Híbrido clásico + post-cuántico
```bash
# Combinar ECDHE + ML-KEM (requiere OpenSSL 3.0+)
```

**Fase 3 (2027+)**: Post-cuántico puro
```bash
# Certificados con ML-DSA cuando esté disponible
```

###  Archivo postcuanticos.txt

Contiene recomendaciones actualizadas sobre algoritmos post-cuánticos.

---

### Casos de Uso

###  Caso 1: Sitio Web HTTPS (Let's Encrypt)

**Objetivo**: Proteger sitio web con certificado DV

```bash
# Instalar Certbot
sudo apt-get install certbot python3-certbot-nginx

# Generar certificado (automático)
sudo certbot certonly --nginx -d ejemplo.com -d www.ejemplo.com

# Renovación automática (cada 90 días)
sudo certbot renew --quiet

# Verificar certificado
openssl x509 -in /etc/letsencrypt/live/ejemplo.com/cert.pem -text -noout
```

**Archivos generados**:
- `cert.pem` - Certificado
- `privkey.pem` - Clave privada
- `chain.pem` - Cadena intermedia
- `fullchain.pem` - Certificado + cadena

**Configuración Nginx**:
```nginx
server {
    listen 443 ssl;
    server_name ejemplo.com;
    
    ssl_certificate /etc/letsencrypt/live/ejemplo.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/ejemplo.com/privkey.pem;
}
```

###  Caso 2: VPN con Certificados Personalizados

**Objetivo**: PKI privada para VPN empresarial

```bash
# 1. Generar CA raíz
sh generacert.sh

# 2. Generar certificado servidor VPN
openssl req -new -nodes \
  -keyout vpn-server.key \
  -out vpn-server.csr \
  -subj "/C=ES/O=Empresa/CN=vpn.empresa.local"

# 3. Firmar con CA
openssl x509 -req -in vpn-server.csr \
  -CA MyRootCA.pem \
  -CAkey MyRootCA.key \
  -CAcreateserial \
  -out vpn-server.crt \
  -days 365 -sha256

# 4. Configurar OpenVPN
cp MyRootCA.pem /etc/openvpn/ca.crt
cp vpn-server.crt /etc/openvpn/server.crt
cp vpn-server.key /etc/openvpn/server.key
```

###  Caso 3: TLS Mutuo (Cliente + Servidor)

**Objetivo**: Autenticación bidireccional segura

```bash
# 1. Crear certificado cliente
openssl req -new -nodes \
  -keyout client.key \
  -out client.csr \
  -subj "/C=ES/O=Empresa/CN=usuario@empresa.local"

# 2. Firmar certificado cliente
openssl x509 -req -in client.csr \
  -CA MyRootCA.pem \
  -CAkey MyRootCA.key \
  -CAcreateserial \
  -out client.crt \
  -days 365 -sha256

# 3. Crear PKCS#12 para importar en navegador/app
openssl pkcs12 -export \
  -out client.p12 \
  -inkey client.key \
  -in client.crt \
  -certfile MyRootCA.pem

# 4. Configurar servidor (Apache ejemplo)
SSLCertificateFile server.crt
SSLCertificateKeyFile server.key
SSLCACertificateFile MyRootCA.pem
SSLVerifyClient require
SSLVerifyDepth 2
```

###  Caso 4: Firma de Correo Electrónico (S/MIME)

```bash
# Crear certificado S/MIME
openssl req -new -x509 \
  -keyout email.key \
  -out email.crt \
  -days 365 \
  -subj "/C=ES/CN=usuario@empresa.com"

# Convertir a PKCS#12 para Outlook/Thunderbird
openssl pkcs12 -export \
  -out email.p12 \
  -inkey email.key \
  -in email.crt

# Firmar correo
openssl smime -sign -in mensaje.txt \
  -signer email.crt \
  -inkey email.key \
  -out mensaje.smime

# Verificar firma
openssl smime -verify -in mensaje.smime \
  -CAfile MyRootCA.pem
```

###  Caso 5: Certificado Auto-Firmado Local (Desarrollo)

```bash
# Generar en UN comando
openssl req -x509 -newkey rsa:2048 \
  -keyout dev.key \
  -out dev.crt \
  -days 365 \
  -nodes \
  -subj "/CN=localhost"

# Crear certificado + clave en un archivo
cat dev.crt dev.key > dev.pem

# Usar en servidor Node.js
const https = require('https');
const fs = require('fs');

const options = {
  key: fs.readFileSync('dev.key'),
  cert: fs.readFileSync('dev.crt')
};

https.createServer(options, (req, res) => {
  res.end('Servidor HTTPS seguro');
}).listen(443);
```

---

### Solucion:

###  Problemas comunes

| Problema | Causa | Solución |
|----------|-------|----------|
| **"certificate verify failed"** | Cadena incompleta | Verificar orden: leaf → intermediate → root |
| **"unable to load certificate"** | Formato incorrecto | Convertir con `openssl x509` |
| **"key values mismatch"** | Clave privada no coincide | Comparar hashes MD5 |
| **"certificate has expired"** | Certificado vencido | Renovar antes de expiración |
| **"common name mismatch"** | CN no coincide con dominio | Regenerar con CN correcto o añadir SAN |
| **"CA is not a CA"** | basicConstraints incorrecto | Regenerar con CA:TRUE |
| **"self signed certificate"** | Navegador no confía | Importar CA raíz en navegador |
| **"ERR_SSL_VERSION_OR_CIPHER_MISMATCH"** | TLS incompatible | Actualizar servidor/cliente |

### 🔧 Diagnóstico

#### Verificar certificado completo

```bash
# Ver TODO (sujeto, validez, algoritmo, extensiones)
openssl x509 -in cert.pem -text -noout

# Ver solo lo importante
openssl x509 -in cert.pem -noout -subject -issuer -dates
```

#### Probar con servidor

```bash
# Ver qué certificado envía el servidor
openssl s_client -connect ejemplo.com:443 -showcerts

# Guardar certificado desde servidor
openssl s_client -connect ejemplo.com:443 \
  -showcerts </dev/null | \
  openssl x509 -out server-cert.pem

# Verificar ese certificado
openssl verify -CAfile ca.pem server-cert.pem
```

#### Depurar CSR

```bash
# Verificar que CSR tiene todo correcto
openssl req -in cert.csr -text -noout

# Verificar que extensiones están presentes
openssl req -in cert.csr -text -noout | grep -A10 "Requested Extensions"
```

---

## Referencias

### Estándares Oficiales

-  [RFC 5280](https://tools.ietf.org/html/rfc5280) - X.509 PKI Certificate and CRL Profile
-  [RFC 6234](https://tools.ietf.org/html/rfc6234) - US Secure Hash Algorithms
-  [RFC 7231](https://tools.ietf.org/html/rfc7231) - HSTS
-  [RFC 6960](https://tools.ietf.org/html/rfc6960) - OCSP Protocol
-  [X.690](https://www.itu.int/rec/T-REC-X.690/en) - DER Encoding

###  Guías de Seguridad

-  [Mozilla SSL Configuration Generator](https://ssl-config.mozilla.org/)
-  [OWASP - Cryptographic Failures](https://owasp.org/Top10/A02_2021-Cryptographic_Failures/)
-  [NIST SP 800-175B](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-175B.pdf)
-  [NCSC Guidelines](https://www.ncsc.gov.uk/collection/mobile-device-guidance/using-built-in-platform-features/tls-ssl-and-https)

###  Herramientas

-  [OpenSSL](https://www.openssl.org/) - Estándar de facto
-  [Certbot](https://certbot.eff.org/) - Automatización Let's Encrypt
-  [XCA](http://xca.sourceforge.net/) - GUI para gestión PKI
-  [cfssl](https://github.com/cloudflare/cfssl) - PKI toolkit Cloudflare
-  [STEP CA](https://smallstep.com/certificates/) - PKI moderna

### Lectura Recomendada

-  "Cryptography Engineering" - Ferguson, Schneier, Kohno
-  "Public Key Cryptography - Practice & Protocols" - Buchmann
-  [OpenSSL Cookbook](https://www.feistyduck.com/books/openssl-cookbook/) - Ivan Ristic

---

### Estructura del Repositorio

```
certificado/
├── README.md                    # Este archivo (mejorado)
├── LICENSE                      # GPL-3.0
├── ca.jpg                       # Diagrama de CA
├── generacert.sh                # Generar CA + autocertificado
├── gencerts.sh                  # Generar múltiples certificados
├── gentlscert.sh                # Generar certificado TLS específico
├── checkcerts.sh                # Verificar certificados
├── curlssl.sh                   # Probar HTTPS con curl
├── tlsx.sh                      # Análisis detallado TLS
├── verifica_ca.sh               # Verificar cadena CA
├── instalar.sh                  # Instalar dependencias
├── apache.txt                   # Configuración Apache
├── recomendaciones.txt          # Guía de recomendaciones
└── postcuanticos.txt            # Información post-cuántica
```

---

### Quick Start

### Generar CA raíz en 30 segundos

```bash
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 -out ca.crt
```

### Crear certificado servidor

```bash
openssl req -new -keyout server.key -out server.csr -nodes
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 365 -sha256
```

### Verificar cadena

```bash
openssl verify -CAfile ca.crt server.crt
```

###  Ver detalles

```bash
openssl x509 -in server.crt -text -noout
```

---

#
http://www.hackingyseguridad.com/
#

---
