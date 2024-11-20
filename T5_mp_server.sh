#!/bin/bash
## Variable Region
_script="$(readlink -f ${BASH_SOURCE[0]})"
# Delete last component from $_script
_mydir="$(dirname $_script)"
# Name of the server shown in the title of the terminal window
NAME="TDM 1"
# Your Game Path (where there is binkw32.dll)
PAT=~/T5Server/Server
# Paste the server key from environment variable
KEY="$SERVER_KEY"
# Name of the config file the server should use (using env variable)
CFG="$SERVER_CFG"
# Port used by the server (using env variable)
PORT="$SERVER_PORT"
# Game Mode ( Multiplayer / Zombie )
MODE="$SERVER_MODE"
# Mod name (default "")
MOD=""
## End Region

## Update Region
# Plutonium game dir
INSTALLDIR=~/T5Server/Plutonium

# Update your server game file
./plutonium-updater -d "$INSTALLDIR"
## End Region

## Server Start Region
echo -e '\033]2;'Plutonium - $NAME - Server restart'\007'
echo "Visit plutonium.pw | Join the Discord (plutonium) for NEWS and Updates!"
echo "Server "$NAME" will load $CFG and listen on port $PORT UDP!"
echo "To shut down the server close this window first!"
printf -v NOW '%(%F_%H:%M:%S)T' -1
echo ""$NOW" $NAME server started."

while true
do
wine .\\bin\\plutonium-bootstrapper-win32.exe $MODE $PAT -dedicated +start_map_rotate +set key $KEY +set fs_game $MOD +set net_port $PORT +set sv_config $CFG 2> /dev/null
printf -v NOW '%(%F_%H:%M:%S)T' -1
echo ""$NOW" WARNING: $NAME server closed or dropped... server restarting."
sleep 1
done
## End Region
