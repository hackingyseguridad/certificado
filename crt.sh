#!/bin/bash
# Busca FQDN por dominio y filtra solo common_name

curl -s "https://crt.sh/api/v1/domain?q=$1&output=json" | \
  python -m json.tool 2>/dev/null | \
  grep -i '"common_name"' | \
  sed 's/.*"common_name": "\(.*\)",*/\1/' | \
  sort -u
# Si no se extrajo ningún resultado, avisar y mostrar un fragmento crudo para depurar
RESULT=$(echo "$RAW" | grep -o '"name_value":"[^"]*"')
if [ -z "$RESULT" ]; then
    echo "Aviso: no se encontraron FQDN. Respuesta cruda (primeros 300 caracteres):" >&2
    echo "$RAW" | cut -c1-300 >&2
fi
