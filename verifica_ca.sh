#!/bin/sh
# Verifica confiabilidad de la CA Entidad Certicadora , un dominio o fqdn
echo

cat << 'EOF'
verifica confiabilidad de la CA entidad certificadora (PKI) de un dominio o FQDN

$$$$ $$$$ $$$$$$$$$$$$$$$$$ $$$$ $$$$$$$$$ $$$$$$$ $$$$$$$$$$$$$$$$$$$$$$$ $$ $$
EOF

DOMAIN="$1"
echo
echo "================================================"
host $1
echo "================================================"
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
        REASON="intermedia + raíz del sistema"
    fi
fi

echo $1 
echo
if [ $TRUSTED -eq 1 ]; then
    echo "CERTIFICADO CONFIABLE !!!"
    echo "  • Razón: $REASON"
else
    echo "CERTIFICADO NO CONFIABLE !!!"
fi



