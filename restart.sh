#!/bin/bash
echo "Restarting T5 Server..."

# Attach to the screen session and terminate it
docker exec t5server screen -S T5Server -X quit

# Start a new server session in the background
docker exec t5server screen -S T5Server -dm /root/T5Server/Plutonium/T5_zm_server.sh

echo "T5 Server restarted."
