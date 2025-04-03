#!/bin/bash
# (R hacking y seguridad .com 2025
# Ginstlar tlsx

echo "Instala tlsx"
echo "https://github.com/projectdiscovery/tlsx"
echo

cd /tmp/
wget https://github.com/projectdiscovery/tlsx/releases/download/v1.1.9/tlsx_1.1.9_linux_amd64.zip
unzip tlsx_1.1.9_linux_amd64.zip
chmod +x tlsx
sudo  mv tlsx /usr/local/bin/
echo
echo "..."
echo
