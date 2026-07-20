#!/bin/sh
#
# crtfqdn.sh - Lista los FQDN de un dominio usando crt.sh (Certificate Transparency)
# Compatible con Bash antiguo (3.x) / sh POSIX.
#
# Uso: ./crtfqdn.sh dominio.com
#

DOMAIN="$1"

if [ -z "$DOMAIN" ]; then
    echo "Uso: $0 <dominio>" >&2
    exit 1
fi

URL="https://crt.sh/?q=%25.${DOMAIN}&output=json"

# Petición con User-Agent, seguimiento de redirects y timeout
RAW=$(curl -s -L -A "Mozilla/5.0 (X11; Linux x86_64)" --max-time 30 "$URL")

if [ -z "$RAW" ]; then
    echo "Error: crt.sh no devolvió ninguna respuesta (puede estar caído o lento)." >&2
    exit 2
fi

echo "$RAW" | grep -o '"name_value":"[^"]*"' \
  | sed -e 's/"name_value":"//' -e 's/"$//' \
  | sed 's/\\n/\n/g' \
  | tr '[:upper:]' '[:lower:]' \
  | sort -u

# Si no se extrajo ningún resultado, avisar y mostrar un fragmento crudo para depurar
RESULT=$(echo "$RAW" | grep -o '"name_value":"[^"]*"')
if [ -z "$RESULT" ]; then
    echo "Aviso: no se encontraron FQDN. Respuesta cruda (primeros 300 caracteres):" >&2
    echo "$RAW" | cut -c1-300 >&2
fi
