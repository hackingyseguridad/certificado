
#!/bin/bash
# Busca FQDN por dominio y filtra solo common_name
# @antonio_taboada

curl -s "https://crt.sh/api/v1/domain?q=$1&output=json" | \
  python -m json.tool 2>/dev/null | \
  grep -i '"common_name"' | \
  sed 's/.*"common_name": "\(.*\)",*/\1/' | \
  sort -u

RESULT=$(echo "$RAW" | grep -o '"name_value":"[^"]*"')

echo "$RAW" | cut -c1-300 >&2
