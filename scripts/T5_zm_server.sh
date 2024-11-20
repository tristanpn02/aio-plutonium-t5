#!/bin/bash
# Set variables using environment variables
NAME="$SERVER_NAME"
PAT=~/T5Server/Server
KEY="$SERVER_KEY"
CFG="$SERVER_CFG"
PORT="$SERVER_PORT"
MODE="$SERVER_MODE"
MOD=""

INSTALLDIR=~/T5Server/Plutonium

# Update your server game files
"$INSTALLDIR/plutonium-updater" -d "$INSTALLDIR"

# Start the server
echo -e "\033]2;Plutonium - $NAME - Server restart\007"
echo "Launching server $NAME using $CFG on port $PORT (mode: $MODE)"
printf -v NOW '%(%F_%H:%M:%S)T' -1
echo "$NOW $NAME server started."

while true; do
    wine ./bin/plutonium-bootstrapper-win32.exe $MODE $PAT -dedicated +start_map_rotate \
        +set key $KEY +set fs_game $MOD +set net_port $PORT +set sv_config $CFG 2>/dev/null
    printf -v NOW '%(%F_%H:%M:%S)T' -1
    echo "$NOW WARNING: $NAME server crashed. Restarting in 5 seconds."
    sleep 5
done
