#!/bin/sh
HYPERV_IF_MAC=$(ipconfig.exe /all | grep -B0 -a5 '(WSL)' | grep -Po ' : \K[0-9A-F-]{17}' | awk '{gsub ( "-"," " ) ; print tolower($0)}')
HYPERV_IF_LINE=$(route.exe print | grep "$HYPERV_IF_MAC")
HYPERV_IF_NUM=$(echo "$HYPERV_IF_LINE" | grep -Po '[^0-9]*\K[0-9]+' | head -n 1)
HYPERV_IP=$(ip addr | grep eth0 -B0 -a3 | grep -Po 'inet \K[0-9\\.]*')
 
echo "Applying on-link route to $HYPERV_IP on interface $HYPERV_IF_LINE"
powershell.exe -NoProfile -Command \
  "Start-Process route.exe \"add $HYPERV_IP mask 255.255.255.255 $HYPERV_IP metric 256 if $HYPERV_IF_NUM\" -Verb RunAs"
