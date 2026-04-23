#!/bin/sh
# Verifica confiabilidad de la CA Entidad Certicadora , un dominio o fqdn
# https://github.com/hackingyseguridad/certificado/
echo

cat << 'EOF'
Verifica confiabilidad de la CA entidad certificadora (PKI) de un dominio o FQDN
Conecta al puerto 443 del dominio dado y extrae la cadena de certificados (incluyendo posibles intermediarios) usando openssl s_client.

1: Valida el certificado directamente contra el almacén de CA del sistema.
2: Verifica si el certificado es autónomo (autofirmado o cadena completa incluida).
3: Extrae posibles certificados intermedios del chain recibido y usarlos con la CA raíz del sistema para validar el certificado final.

Muestra la entidad emisora

CONFIABLE si alguna de las tres validaciones anteriores tiene éxito, mostrando la razón.
NO CONFIABLE si todas fallan.

$$$$ $$$$ $$$$$$$$$$$$$$$$$ $$$$ $$$$$$$$$ $$$$$$$ $$$$$$$$$$$$$$$$$$$$$$$ $$ $$

https://github.com/hackingyseguridad/certificado/
EOF

echo
nmap  -Pn -p 110,993,995,143,443,587,465,5061,8000,7443,8443,8080,8888,10443 --open --script=ssl-cert $1 $2 --defeat-rst-ratelimit
echo
echo "buscando subdominios/fqdn de: " $1
sublist3r -d $1
DOMAIN="$1"

TEMP_CHAIN="/tmp/chain_$$.pem"
TEMP_CERT="/tmp/cert_$$.pem"

cleanup() { rm -f "$TEMP_CHAIN" "$TEMP_CERT" /tmp/cert_*_$$.pem 2>/dev/null; }
trap cleanup EXIT
echo
echo "= DOMINIO ======================================="
host "$DOMAIN"
echo "================================================="
echo

# Corrección: opensssl -> openssl
# Obtener cadena completa
printf "Q\n" | openssl s_client -connect "$DOMAIN:443" -servername "$DOMAIN" -showcerts 2>/dev/null | \
sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' > "$TEMP_CHAIN"

# Separar certificados usando awk en lugar de csplit (más compatible)
awk 'BEGIN {n=0; cert=""} /-----BEGIN CERTIFICATE-----/ {cert=""; n++} {cert = cert $0 "\n"} /-----END CERTIFICATE-----/ {printf "%s", cert > sprintf("/tmp/cert_%02d_'"$$"'.pem", n)}' "$TEMP_CHAIN"

CERT_FILES=$(ls /tmp/cert_*_$$.pem 2>/dev/null)

echo "= CADENA DE CERTIFICACIÓN ========================"

i=0
ROOT_CA=""
INTERMEDIATE_CA=""
ORG=""
TYPE="Privada"
LAST_SUBJECT=""
LAST_ISSUER=""

for cert in $CERT_FILES; do
    if grep -q "BEGIN CERTIFICATE" "$cert"; then
        i=$((i+1))

        SUBJECT=$(openssl x509 -in "$cert" -noout -subject 2>/dev/null)
        ISSUER=$(openssl x509 -in "$cert" -noout -issuer 2>/dev/null)

        # Limpiar prefijos "subject=" e "issuer="
        SUBJECT=$(echo "$SUBJECT" | sed 's/^subject=//')
        ISSUER=$(echo "$ISSUER" | sed 's/^issuer=//')

        echo "[$i]"
        echo "  Subject: $SUBJECT"
        echo "  Issuer : $ISSUER"

        # Extraer organización del subject
        O=$(echo "$SUBJECT" | sed -n 's/.*O=\([^,/]*\).*/\1/p')
        if [ -n "$O" ]; then
            ORG="$O"
        fi

        # Si no hay O en subject, buscar en issuer
        if [ -z "$ORG" ]; then
            O=$(echo "$ISSUER" | sed -n 's/.*O=\([^,/]*\).*/\1/p')
            [ -n "$O" ] && ORG="$O"
        fi

        # Detectar root CA (self-signed o mismo subject/issuer)
        if [ "$SUBJECT" = "$ISSUER" ]; then
            ROOT_CA="$SUBJECT"
        else
            # Si no hay root detectada aún, esta podría ser intermedia
            if [ -z "$ROOT_CA" ]; then
                INTERMEDIATE_CA="$SUBJECT"
            fi
        fi

        # También verificar si el issuer es el mismo que algún subject anterior (relación jerárquica)
        if [ -n "$LAST_SUBJECT" ] && [ "$ISSUER" = "$LAST_SUBJECT" ]; then
            INTERMEDIATE_CA="$LAST_SUBJECT"
        fi

        LAST_SUBJECT="$SUBJECT"
        LAST_ISSUER="$ISSUER"
        echo
    fi
done

# Si no se encontró root por auto-firma, la última es la raíz
if [ -z "$ROOT_CA" ] && [ $i -gt 0 ]; then
    LAST_CERT=$(echo "$CERT_FILES" | tail -1)
    if [ -f "$LAST_CERT" ]; then
        ROOT_CA=$(openssl x509 -in "$LAST_CERT" -noout -subject 2>/dev/null | sed 's/^subject=//')
    fi
fi

echo "================================================="
echo

echo "= RESUMEN PKI ==================================="
echo "Organización (O): ${ORG:-Desconocida}"
echo "CA Raíz         : ${ROOT_CA:-No detectada}"
echo "CA Intermedia   : ${INTERMEDIATE_CA:-No detectada}"

# Clasificación pública/privada basada en nombres de CAs conocidas
if [ -n "$ROOT_CA" ]; then
    echo "$ROOT_CA" | grep -Ei "DigiCert|GlobalSign|Let'?s Encrypt|Sectigo|Entrust|GoDaddy|ISRG|Amazon|Google|Microsoft|Cisco|Comodo|GeoTrust|Thawte|RapidSSL|Network Solutions|VeriSign|Cybertrust|SwissSign|Deutsche Telekom|QuoVadis|Buypass|Certum|T-Systems|IdenTrust|Actalis|CAMERFIRMA|Chambers of Commerce|Disig|E-Tugra|HARICA|Hongkong Post|Microsec|NetLock|OISTE|SECOM|TrustCor|TWCA|TurkTrust" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        TYPE="Pública"
    else
        # Verificar si es una CA privada (empresarial/local)
        echo "$ROOT_CA" | grep -Eiq "(Internal|Private|Local|Dev|Test|Lab|Corp|Enterprise|Company)" && TYPE="Privada (Empresarial)" || TYPE="Posiblemente Privada"
    fi
fi

echo "Tipo PKI        : $TYPE"
echo "================================================="
echo

# ================= VALIDACIÓN ORIGINAL =================

CA_FILE=""
[ -f "/etc/ssl/certs/ca-certificates.crt" ] && CA_FILE="/etc/ssl/certs/ca-certificates.crt"
[ -f "/etc/pki/tls/certs/ca-bundle.crt" ] && CA_FILE="/etc/pki/tls/certs/ca-bundle.crt"
[ -f "/etc/ssl/cert.pem" ] && CA_FILE="/etc/ssl/cert.pem"
[ -f "/etc/ssl/certs/ca-bundle.crt" ] && CA_FILE="/etc/ssl/certs/ca-bundle.crt"

# Certificado leaf (primer certificado de la cadena)
awk 'BEGIN{c=0} /BEGIN CERT/{c++} c==1 {print} /END CERT/ && c==1 {exit}' "$TEMP_CHAIN" > "$TEMP_CERT"

TRUSTED=0
REASON=""

if [ -n "$CA_FILE" ] && openssl verify -CAfile "$CA_FILE" "$TEMP_CERT" >/dev/null 2>&1; then
    TRUSTED=1
    REASON="CA raíz reconocida por el sistema"
fi

if [ $TRUSTED -eq 0 ] && openssl verify -CAfile "$TEMP_CHAIN" "$TEMP_CERT" >/dev/null 2>&1; then
    TRUSTED=1
    REASON="cadena completa autónoma"
fi

if [ $TRUSTED -eq 0 ] && [ -n "$CA_FILE" ]; then
    sed -n '2,$p' "$TEMP_CHAIN" > "$TEMP_CERT.intermediate"
    if openssl verify -untrusted "$TEMP_CERT.intermediate" -CAfile "$CA_FILE" "$TEMP_CERT" >/dev/null 2>&1; then
        TRUSTED=1
        REASON="cadena con intermedia válida"
    fi
fi

echo "= RESULTADO ====================================="

if [ $TRUSTED -eq 1 ]; then
    echo "CERTIFICADO CONFIABLE"
    echo "  • $REASON"
else
    echo "CERTIFICADO NO CONFIABLE"
    if [ -n "$TYPE" ] && [ "$TYPE" = "Privada" ] || [ "$TYPE" = "Privada (Empresarial)" ]; then
        echo "  • Posible certificado de CA privada no instalada en el sistema"
    fi
fi

echo "================================================="
echo



