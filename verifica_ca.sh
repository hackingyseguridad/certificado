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

DOMAIN="$1"
echo
echo "= DOMINIO ======================================="
host $1
echo "================================================="
echo
TEMP_CERT="/tmp/cert_$$.pem"
TEMP_CHAIN="/tmp/chain_$$.pem"
cleanup() { rm -f "$TEMP_CERT" "$TEMP_CHAIN" "$TEMP_CERT.intermediate" 2>/dev/null; }
trap cleanup EXIT

# Obtener certificado
printf "Q\n" | openssl s_client -connect "$DOMAIN:443" -servername "$DOMAIN" -showcerts 2>/dev/null | \
    sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' > "$TEMP_CHAIN"

# Validar que hay contenido
if [ ! -s "$TEMP_CHAIN" ]; then
    echo "Error: no se pudo obtener el certificado de $DOMAIN"
    exit 2
fi

# Extraer primer certificado
awk 'BEGIN{c=0} /BEGIN CERT/{c++} c==1 {print} /END CERT/ && c==1 {exit}' "$TEMP_CHAIN" > "$TEMP_CERT"

# Detectar CA
CA_FILE=""
[ -f "/etc/ssl/certs/ca-certificates.crt" ] && CA_FILE="/etc/ssl/certs/ca-certificates.crt"
[ -f "/etc/pki/tls/certs/ca-bundle.crt" ] && CA_FILE="/etc/pki/tls/certs/ca-bundle.crt"
[ -f "/etc/ssl/cert.pem" ] && CA_FILE="/etc/ssl/cert.pem"

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
        REASON="Hay al menos 3 niveles: CA Raíz (Root), CA Intermedia y Certificado Final (Leaf)."
    fi
fi
echo
echo "= Entidad emoisora del certicado/CA ============="
openssl s_client -connect $1:443 -servername $1 2>/dev/null \
| openssl x509 -noout -issuer
echo "================================================="
echo

if [ $TRUSTED -eq 1 ]; then
    echo "CERTIFICADO CONFIABLE !!!"
    echo "  • Razón: $REASON"
else
    echo "CERTIFICADO NO CONFIABLE !!!"
fi


