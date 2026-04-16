#!/bin/sh
# Verifica entidad certicadora CA de un dominio

DOMAIN="$1"
TEMP_CERT="/tmp/cert_$$.pem"
TEMP_CHAIN="/tmp/chain_$$.pem"

cleanup() { rm -f "$TEMP_CERT" "$TEMP_CHAIN" 2>/dev/null; }
trap cleanup EXIT

# Obtener certificado y cadena
echo "Q" | openssl s_client -connect "$DOMAIN:443" -servername "$DOMAIN" -showcerts 2>/dev/null | \
    sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' > "$TEMP_CHAIN"

# Extraer primer certificado
sed -n '1,/END CERTIFICATE/p' "$TEMP_CHAIN" > "$TEMP_CERT"

# Detectar CA bundle del sistema
CA_FILE=""
[ -f "/etc/ssl/certs/ca-certificates.crt" ] && CA_FILE="/etc/ssl/certs/ca-certificates.crt"
[ -f "/etc/pki/tls/certs/ca-bundle.crt" ] && CA_FILE="/etc/pki/tls/certs/ca-bundle.crt"

# Lógica de verificación CORREGIDA
TRUSTED=0
REASON=""

# Intento 1: Contra CA del sistema
if [ -n "$CA_FILE" ] && openssl verify -CAfile "$CA_FILE" "$TEMP_CERT" 2>/dev/null; then
    TRUSTED=1
    REASON="CA raíz reconocida por el sistema"
fi

# Intento 2: Cadena completa autónoma
if [ $TRUSTED -eq 0 ] && openssl verify -CAfile "$TEMP_CHAIN" "$TEMP_CERT" 2>/dev/null; then
    TRUSTED=1
    REASON="cadena completa autónoma (PKI válida)"
fi

# Intento 3: Cadena intermedia + CA sistema
if [ $TRUSTED -eq 0 ] && [ -n "$CA_FILE" ]; then
    # Extraer CA intermedia (certificados 2..n)
    sed -n '2,$ p' "$TEMP_CHAIN" > "$TEMP_CERT.intermediate"
    if openssl verify -untrusted "$TEMP_CERT.intermediate" -CAfile "$CA_FILE" "$TEMP_CERT" 2>/dev/null; then
        TRUSTED=1
        REASON="CA intermedia válida + CA raíz del sistema"
    fi
fi

# Mostrar resultado FINAL consistente
echo "========================================="
echo "RESULTADO FINAL"
echo "========================================="
if [ $TRUSTED -eq 1 ]; then
    echo "✓ CERTIFICADO CONFIABLE"
    echo "  • Razón: $REASON"
    exit 0
else
    echo "✗ CERTIFICADO NO CONFIABLE"
    echo "  • No se pudo verificar por ningún método"
    exit 1
fi

